`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/12 12:29:45
// Design Name: 
// Module Name: clock
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


module cpuclock(
input fpga_clk,
output clock
);
cpuclk cpuclk(
.clk_in1(fpga_clk),	    // 100MHz, 板上时钟
.clk_out1(clock)    	    // CPU Clock (23MHz), 主时钟
);
endmodule
