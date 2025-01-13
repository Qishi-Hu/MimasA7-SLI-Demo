`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2025 04:30:30 PM
// Design Name: 
// Module Name: clk_selector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module clk_selector (
    input hdmi_clk, 
    input local_clk,    
    output sel
);
    
    reg s= 1'b0; reg lo = 1'b0; reg hi = 1'b0;
    reg [27:0] count = 0;  // check period 
    reg [8:0] cnt = 0; // cnt[8] is the slow version of hdmi input clock
    always@(posedge hdmi_clk) begin
        cnt <= cnt+1;
    end
   always@(posedge local_clk) begin
        count<= count+1;
        if (count[27]) begin
            if(hi && lo ) s<=1'b0;
            else s<= 1'b1;
        end
        else if (count==0) begin
            lo<=1'b0; hi<=1'b0;
        end
        else begin
            if(cnt[8]) hi <=1'b1;
            else lo <=1'b1;
        end     
   end
    
    assign sel =s;
   

endmodule
