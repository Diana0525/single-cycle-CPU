`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/10 14:53:48
// Design Name: 
// Module Name: control32
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

//根据当前取出的指令生成不同的控制信号控制执行单元、取指单元、译码单元
module control32(
input [31:0]Instruction,//来自取指单元的指令
input Zero,//来自执行单元，为1表示运算结果为0
input Zero_bgtz,//来自执行单元，bgtz的标志位，为1表示rs>0
output branch,//beq的分支信号，传递给取指单元，高电平表示有分支
output bne_branch,
output jr,//传递给取指单元
output Jal,//传递给译码单元、取指单元
output beq,//传递给取指单元
output bne,
output jmp,//传递给取指单元
output RegWrite,//传递给译码单元，当有数据要写入寄存器时，置1
output MemorIOtoReg,//传递给译码单元，当有来自存储器的数据要写入寄存器时，置1
output Memorywrite,//sw指令时置1，写入存储单元
output rtORrd,//传递给译码单元，控制写入rt还是rd,为1表示写入[20:16]rt,否则表示写入[15:11]rd
output [2:0]ALU_op,//传递给执行单元，八种ALU_op
output slttu,//传递给执行单元，表示指令是slt or sltu
output [1:0]B_Sel//传递给执行单元，B端输入的多路选择,00表示寄存器，01表示立即数,11表示0
    );
parameter ADD = 3'b000,
            SUB = 3'b001,
            AND = 3'b010,
            OR = 3'b011,
            XOR = 3'b100,
            NOR =3'b101,
            MOVE = 3'b110,
            COMPARE = 3'b111;
reg [2:0]ALU_op_temp;
reg [1:0]B_Sel_temp;
assign ALU_op = ALU_op_temp;
assign B_Sel = B_Sel_temp;
assign branch = (Instruction[31:26] == 6'b000100 && Zero)?1:0;//若当前指令为beq，并且运算单元得到的运算结果为0，则置1
assign bne_branch = (Instruction[31:26] == 6'b000101 && !Zero)?1:0;//若当前指令为bne，并且运算得到的结果不为0，则表示要跳转，置1
assign jr = (Instruction[31:26] == 6'b0 && Instruction[5:0] == 6'b001000)?1:0;//若当前指令是jr指令，则置1
assign Jal = (Instruction[31:26] == 6'b000011)?1:0;//若当前指令是Jal，则置1
assign beq = (Instruction[31:26] == 6'b000100)?1:0;//若当前指令是beq，则置1
assign bne = (Instruction[31:26] == 6'b000101)?1:0;//若当前指令是bne，则置1
assign jmp = (Instruction[31:26] == 'b000010)?1:0;//若当前指令是j，则置1
assign RegWrite = ((jr == 1'b1) || (Instruction[31:26] == 6'b101011)//jr或sw指令
                 || (Instruction[31:26] == 6'b000100)//beq
                 || (Instruction[31:26] == 6'b000101)//bne
                 || (Instruction[31:26] == 6'b000111)//bgtz
                 || (Instruction[31:26] == 6'b000010)//j
                 )?0:1;//除了上述列出的指令外，都需要写寄存器
assign MemorIOtoReg = (Instruction[31:26] == 6'b100011)?1:0;//当指令为lw时需要置1，表示写入寄存器的内容来自存储单元
assign Memorywrite = (Instruction[31:26] == 6'b101011)?1:0;
assign rtORrd = ((Instruction[31:26] == 6'b001000)//addi
                || (Instruction[31:26] == 6'b001001)//addiu
                || (Instruction[31:26] == 6'b001100)//andi
                || (Instruction[31:26] == 6'b001101)//ori
                || (Instruction[31:26] == 6'b001110)//xori
                || (Instruction[31:26] == 6'b001011)//sltiu
                || (Instruction[31:26] == 6'b001111)//lui
                || (Instruction[31:26] == 6'b100011)//lw
                )?1:0;//当指令为上述指令时，置1表示写入rt寄存器
assign slttu = ((Instruction[31:26] == 6'b0 && Instruction[5:0] == 6'b101010)//slt
                || (Instruction[31:26] == 6'b0 && Instruction[5:0] == 6'b101011)//sltu
                ||(Instruction[31:26] == 6'b001011)//sltiu
                )?1:0;//为上述指令时置1
//ALU_op译码
always @(*) begin
    if(Instruction[31:26] == 6'b0)begin//r型指令分析
        case(Instruction[5:0])
            6'b100000:ALU_op_temp = ADD;
            6'b100001:ALU_op_temp = ADD;
            6'b100010:ALU_op_temp = SUB;
            6'b100011:ALU_op_temp = SUB;
            6'b100100:ALU_op_temp = AND;
            6'b100101:ALU_op_temp = OR;
            6'b100110:ALU_op_temp = XOR;
            6'b100111:ALU_op_temp = NOR;
            6'b101010:ALU_op_temp = COMPARE;
            6'b101011:ALU_op_temp = COMPARE;
            6'b000000:ALU_op_temp = MOVE;
            6'b000010:ALU_op_temp = MOVE;
            6'b000011:ALU_op_temp = MOVE;
            6'b000100:ALU_op_temp = MOVE;
            6'b000110:ALU_op_temp = MOVE;
            6'b000111:ALU_op_temp = MOVE;
        endcase    
    end
    else begin
        case(Instruction[31:26])
            6'b001000:ALU_op_temp = ADD;
            6'b001001:ALU_op_temp = ADD;
            6'b001100:ALU_op_temp = AND;
            6'b001101:ALU_op_temp = OR;
            6'b001110:ALU_op_temp = XOR;
            6'b001011:ALU_op_temp = COMPARE;
            6'b001111:ALU_op_temp = MOVE;
            6'b100011:ALU_op_temp = ADD;//lw
            6'b101011:ALU_op_temp = ADD;
            6'b000100:ALU_op_temp = COMPARE;
            6'b000101:ALU_op_temp = COMPARE;
            6'b000111:ALU_op_temp = COMPARE;
            6'b000010:ALU_op_temp = ADD;
            6'b000011:ALU_op_temp = ADD;
        endcase
    end 
end
//B_Sel译码
//传递给执行单元，B端输入的多路选择,00表示寄存器，01表示立即数,11表示0
always @(*) begin
    if((Instruction[31:26] == 6'b001000)||(Instruction[31:26] == 6'b001001)//addi addiu
        || (Instruction[31:26] == 6'b001100)||(Instruction[31:26] == 6'b001101)//andi ori
        || (Instruction[31:26] == 6'b001110)||(Instruction[31:26] == 6'b001011)//xori sltui
        || (Instruction[31:26] == 6'b001111)||(Instruction[31:26] == 6'b100011)//lui lw
        || (Instruction[31:26] == 6'b101011)||(Instruction[31:26] == 6'b000010)//sw j
        || (Instruction[31:26] == 6'b000011))//jal
        
    begin
        B_Sel_temp = 2'b01;
    end
    else if(Instruction[31:26] == 6'b000111)//bgtz
    begin
        B_Sel_temp = 2'b11;
    end
    else begin
        B_Sel_temp = 2'b00;
    end
end
endmodule
