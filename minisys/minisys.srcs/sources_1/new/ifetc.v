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

//ȡָģ��
module ifetc(
input clock,//ʱ��
input reset,//��λ�źţ��ߵ�ƽ��Ч
input [31:0]ALU_address,//����ִ�е�Ԫ���������ת�ĵ�ַ
input [31:0]j_address,
input [31:0]RA,//�������뵥Ԫ��jr $raָ���õĵ�ַ
//input [31:0]Jpadr,//��ָ��洢����Ԫ�л�ȡ��ָ��
//�����ź����Կ��Ƶ�Ԫ
input branch,//�ߵ�ƽ��ʾ�з�֧
input bne_branch,
input jr,//�ߵ�ƽ��ʾ��jrָ��
input jal,//�ߵ�ƽ��ʾ��jalָ��
input beq,
input bne,
input jmp,
input Zero_bgtz,
//����ź�
output [31:0]Instruction,//�������һģ��ģ��Ѿ�ȡ����ָ��
output wire [31:0]rom_addr,//��ָ��洢����ȡָ��ַ
output [31:0]PC_plus4_out,//PC+4��ִ�е�Ԫ
output reg [31:0]PC_plus4_jal//Jalר��PC+4
);
wire [31:0]PC_plus4;
reg [31:0]PC=32'h00000000;
reg start = 0;//��־ȡָ��Ŀ�ʼ
wire [31:0]Jpadr;
//���䵽ROMģ��
assign rom_addr = PC;
assign Instruction = Jpadr;
programrom rom(
.clock(clock), //ROM clock
.PC(rom_addr),
.Instruction(Jpadr) //ȡ��ָ��
);
//����PC+4��ִ��ģ��
assign PC_plus4_out = PC_plus4;
assign PC_plus4[31:2] = PC[31:2]+1;
assign PC_plus4[1:0] = 2'b00; 
//���½��ؼ�����һ��ָ��ĵ�ַ
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
