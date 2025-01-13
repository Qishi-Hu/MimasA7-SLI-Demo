`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Qihsi Hu
// 
// Create Date: 12/05/2024 08:04:50 PM
// Design Name: 
// Module Name: pixel_pipe
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: process 8-bit RGB pixels
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pixel_pipe(
    input clk, clk10,
    input [1:0] bt,
    input [7:0] in_green,
    input [7:0] in_blue,
    input [7:0] in_red,
    input  in_blank,
    input  in_vsync,
    input in_hsync,
    output sd_cs, sd_clk, sd_mosi, file_found,
    input  sd_miso,
    output reg [3:0] en, 
    output reg [7:0] seg, // { E,D,C,P,B,A,F,G}
    output reg trig,
    output [7:0] out_red,
    output [7:0] out_green,
    output [7:0] out_blue,
    output  out_hsync,
    output out_vsync,
    output out_blank
    );
    parameter V=2'b01; parameter B=2'b10; parameter O=2'b11; //states for Vsync, V back porch + 1st hysnc period, others.
    reg flag=1'b0; // flag for pattern change
    reg [1:0] S, N; // for primary FSM of states V B O 
    reg [7:0] LUT [0:719];
    wire [7:0] fbyte; // LUT file output bytes 
    wire [7:0] fs; //file size [11:4]
    wire fen, rvalid; //LUT file ready to be read
    wire [1:0] ftype; wire [2:0] fstat; // filesystem type and status
    wire [1:0] sdtype; wire [3:0] sdstat; // sd card type and status
    reg sd_rst=1'b0;
    always@(posedge in_vsync)begin
        sd_rst<=1'b1;
        end
    //read SD
    sd_spi_file_reader sd_read(
        .clk(clk10),
        .spi_ssn(sd_cs), .spi_sck(sd_clk), .spi_mosi (sd_mosi),
        .rstn(sd_rst), .outen(fen), .outbyte(fbyte), .rvalid_out(rvalid),
        .filesystem_type(ftype),.filesystem_stat(fstat), .fs(fs),
        .card_type(sdtype),.card_stat(sdstat), 
        .spi_miso(sd_miso), .file_found(file_found)
    );
    
    //mode slection meely FSM
    reg [1:0] st =2'b01; reg [1:0] nxt; //fsm states for selecting pass-through or pattern gen
    reg [1:0] stM =2'b01; reg [1:0] nxtM; //fsm states for selecting orginal output or slow motion
    reg mode= 1'b0; reg slowM =1'b0;
    always@(posedge in_vsync) begin
        if(bt[0]) nxt<=2'b10;
        else nxt<= 2'b01;
        st<=nxt;
        if(~st[0] && nxt[0]) mode<=~mode; //mode switch when button is pushed
    end
    always@(posedge in_vsync) begin
        if(bt[1]) nxtM<=2'b10;
        else nxtM<= 2'b01;
        stM<=nxtM;
        if(~stM[0] && nxtM[0]) slowM<=~slowM; //mode switch when button is pushed
    end
    
    //get LUT
    reg [9:0] i=10'd0; //LUT index
    always@(posedge clk10) begin
        if(fen) begin             
            LUT[i]<= fbyte; 
            if (i < 10'd719)  i <= i + 10'd1; 
        end
    end
   
    //row index tracker
    reg [9:0] row=10'd0;  
    always@(posedge in_hsync) begin
        if(S==O) row<=row+10'd1; //exclude the first hysnc of the frame
        else row<=10'd0;
    end
    //frame index counter with a slow motion feature that holds each frame for 32 frames 
    reg[1:0] frq=2'd0; reg[2:0] fra=3'd0; // spatial frquency index, frame index
    reg[4:0] hold; //hold_counter
    always@(posedge in_vsync) begin
        if (slowM) hold<= hold + 5'd1;
        else hold<=5'd0;
        if (hold==5'd0) begin
            if(fra==3'd7) begin
                if(frq==2'd2) frq<=2'd0;
                else frq<=frq+2'd1;
            end
            fra<=fra+3'd1;
        end
    end  
      
    //index mapping; find the correspoding index in the input LUT, according to current row,frq, and fra
    wire [9:0] index;//target index
    indexMap MAP(.a({frq,fra,row}), .qspo(index), .clk(clk));
    
    //top-left pixel detection
    reg [7:0] TL; //-the top left pixel of current frame
    //FSM
    always@(posedge clk) begin
        case(S) 
            V: N<= in_vsync?V:B;
            B: N<= in_blank?B:O;
            O: N<= in_vsync?V:O;
            default: N<=O; 
        endcase
    end
    //set flag: `1 - in pass-through mode when the TL pixel value changes
    //          2 -  in pattern gen mode, if the current frame is the last during a hold period
    always@(posedge clk) begin
        S<=N;
        if((S==B)&&(N==O)) begin
            if(TL==in_red) begin
                flag<= mode? 1'b0 : (hold==5'd0); TL<=TL;
                end
            else begin
                flag<= mode? 1'b1 :(hold==5'd0); TL<=in_red;
                end
        end
        else begin 
            TL<=TL; flag<= 1'b0;
        end            
    end
   
    //one-hot endcoding FSM for trigger output 8.1 msec (1s/120), that is about 601425 cycles 0x925D1
    // to make life easier we use 0x80000, corresponding 7.06 msec 
    reg [2:0] D=3'b000; //D[2] is trigger ready, D[1] is flag ready waiting for Vsync, D[0] is reset state waiting for flag
    always@(posedge clk) begin
        D[0]<=flag;
        D[1]<=D[0]|(D[1]&(~in_vsync));
        D[2]<=D[1]&in_vsync;
    end
    reg [20:1] cnt=20'h00000; 
    always@(posedge clk) begin
        if (D[2])  begin
            cnt<=20'h00001; // set counter to 1 to begin exposure
            trig<=1'b1;
        end
        else if (cnt[20]) begin
            cnt<=20'h00000; // end of exposure
            trig<=1'b0;
        end
        else if (cnt==20'h00000) begin //rest
            cnt<=cnt;
            trig<=1'b0;
        end
        else begin   //exposure time
            cnt<=cnt+1;
            trig<=1'b1;
        end
    end
    
    
    // set the 7seg display
    reg pos; // 1 for tens , 0 for single digit
    wire [3:0] digit; // The to-be diplayed digit
    always@(posedge in_hsync) begin pos<=~pos; end
    assign digit= mode? (pos?  TL[7:4] : TL[3:0] ): (pos?  {2'b00,frq} : {1'b0,fra} ); 
    //assign digit=pos?  TL[7:4] : TL[3:0]; 
   // assign digit=pos?  {1'b0,fstat} : {2'b00,ftype};  //for debugging LUT
    always@(negedge in_hsync) begin 
        case (digit) // Rev.2  { G,F ,E ,D, P,C ,B ,A}  Rev.3 { E,D,C,P,B,A,F,G}
            4'h0: seg=8'h11;
            4'h1: seg=8'hD7;
            4'h2: seg=8'h32;
            4'h3: seg=8'h92;
            4'h4: seg=8'hD4;
            4'h5: seg=8'h98;
            4'h6: seg=8'h18;
            4'h7: seg=8'hD3;
            4'h8: seg=8'h10;
            4'h9: seg=8'h90;
            4'hA: seg=8'h50;
            4'hB: seg=8'h1C;
            4'hC: seg=8'h39;
            4'hD: seg=8'h16;
            4'hE: seg=8'h38;
            4'hF: seg=8'h78;            
       endcase
       en[1:0]<=pos? 2'b10 : 2'b01;  
    end
    //connect the pipe
    //assign out_red =in_red; assign out_green =in_green;  assign out_blue =in_blue;
   assign out_red = mode? in_red : (in_blank? in_red:LUT[index]); 
   assign out_green = mode? in_green : (in_blank? in_green:LUT[index]);  
   assign out_blue = mode? in_blue : (in_blank? in_blue:LUT[index]);
    assign out_hsync =in_hsync; assign out_vsync =in_vsync;  assign out_blank =in_blank; 
endmodule
