`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/09 16:00:07
// Design Name: 
// Module Name: ifetc
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

//取指模块
module ifetc(
input clock,//时钟
input reset,//复位信号，高电平有效
input [31:0]ALU_address,//来自执行单元，算出的跳转的地址
input [31:0]j_address,
input [31:0]RA,//来自译码单元，jr $ra指令用的地址
//input [31:0]Jpadr,//从指令存储器单元中获取的指令
//控制信号来自控制单元
input branch,//高电平表示有分支
input bne_branch,
input jr,//高电平表示是jr指令
input jal,//高电平表示是jal指令
input beq,
input bne,
input jmp,
input Zero_bgtz,
//输出信号
output [31:0]Instruction,//输出给下一模块的，已经取出的指令
output wire [31:0]rom_addr,//给指令存储器的取指地址
output [31:0]PC_plus4_out,//PC+4送执行单元
output reg [31:0]PC_plus4_jal//Jal专用PC+4
);
wire [31:0]PC_plus4;
reg [31:0]PC=32'h00000000;
reg start = 0;//标志取指令的开始
wire [31:0]Jpadr;
//传输到ROM模块
assign rom_addr = PC;
assign Instruction = Jpadr;
programrom rom(
.clock(clock), //ROM clock
.PC(rom_addr),
.Instruction(Jpadr) //取出指令
);
//传输PC+4给执行模块
assign PC_plus4_out = PC_plus4;
assign PC_plus4[31:2] = PC[31:2]+1;
assign PC_plus4[1:0] = 2'b00; 
//在下降沿计算下一条指令的地址
always @(negedge clock)begin
//    $strobe("PC: %h \n ",PC);
    if (reset)begin
        PC <= 32'h00000000;
        start = 1;
    end
    else if(beq && branch)begin
        PC <= ALU_address;
    end
    else if(bne && bne_branch)begin
        PC <= ALU_address;
    end
    else if(Zero_bgtz)begin
        PC <= ALU_address;
    end
    else if(jr) begin
        PC <= RA;
    end
    else if(jmp) begin
        PC <= {4'h0,Instruction[25:0],2'b00};
    end
    else if(jal) begin
        PC_plus4_jal <= PC_plus4;
        PC <= {4'h0,Instruction[25:0],2'b00};
    end
    else if(start)begin
        PC <= PC;
        start <= 0;
    end
    else begin
        PC <= PC_plus4;
    end
end
endmodule
