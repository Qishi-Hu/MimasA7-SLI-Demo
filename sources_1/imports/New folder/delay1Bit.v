`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Qishi Hu
// 
// Create Date: 12/05/2024 04:28:22 AM
// Design Name: 
// Module Name: delay1Bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Dealy 1-bit by n cycles
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module delay1Bit(
    input clk,
    input d,
    output [2:0] q
    );
    parameter n=8;
    reg [n:1] m;
    integer i;
    always@(posedge clk) begin
        for(i=1;i<=n;i=i+1)  begin
            if(i==1)  m[i]<=d;  
            else  m[i]<=m[i-1]; 
         end
    end
    assign q={m[n-1],m[n-1], m[n-1]};
endmodule
