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

//���ݵ�ǰȡ����ָ�����ɲ�ͬ�Ŀ����źſ���ִ�е�Ԫ��ȡָ��Ԫ�����뵥Ԫ
module control32(
input [31:0]Instruction,//����ȡָ��Ԫ��ָ��
input Zero,//����ִ�е�Ԫ��Ϊ1��ʾ������Ϊ0
input Zero_bgtz,//����ִ�е�Ԫ��bgtz�ı�־λ��Ϊ1��ʾrs>0
output branch,//beq�ķ�֧�źţ����ݸ�ȡָ��Ԫ���ߵ�ƽ��ʾ�з�֧
output bne_branch,
output jr,//���ݸ�ȡָ��Ԫ
output Jal,//���ݸ����뵥Ԫ��ȡָ��Ԫ
output beq,//���ݸ�ȡָ��Ԫ
output bne,
output jmp,//���ݸ�ȡָ��Ԫ
output RegWrite,//���ݸ����뵥Ԫ����������Ҫд��Ĵ���ʱ����1
output MemorIOtoReg,//���ݸ����뵥Ԫ���������Դ洢��������Ҫд��Ĵ���ʱ����1
output Memorywrite,//swָ��ʱ��1��д��洢��Ԫ
output rtORrd,//���ݸ����뵥Ԫ������д��rt����rd,Ϊ1��ʾд��[20:16]rt,�����ʾд��[15:11]rd
output [2:0]ALU_op,//���ݸ�ִ�е�Ԫ������ALU_op
output slttu,//���ݸ�ִ�е�Ԫ����ʾָ����slt or sltu
output [1:0]B_Sel//���ݸ�ִ�е�Ԫ��B������Ķ�·ѡ��,00��ʾ�Ĵ�����01��ʾ������,11��ʾ0
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
assign branch = (Instruction[31:26] == 6'b000100 && Zero)?1:0;//����ǰָ��Ϊbeq���������㵥Ԫ�õ���������Ϊ0������1
assign bne_branch = (Instruction[31:26] == 6'b000101 && !Zero)?1:0;//����ǰָ��Ϊbne����������õ��Ľ����Ϊ0�����ʾҪ��ת����1
assign jr = (Instruction[31:26] == 6'b0 && Instruction[5:0] == 6'b001000)?1:0;//����ǰָ����jrָ�����1
assign Jal = (Instruction[31:26] == 6'b000011)?1:0;//����ǰָ����Jal������1
assign beq = (Instruction[31:26] == 6'b000100)?1:0;//����ǰָ����beq������1
assign bne = (Instruction[31:26] == 6'b000101)?1:0;//����ǰָ����bne������1
assign jmp = (Instruction[31:26] == 'b000010)?1:0;//����ǰָ����j������1
assign RegWrite = ((jr == 1'b1) || (Instruction[31:26] == 6'b101011)//jr��swָ��
                 || (Instruction[31:26] == 6'b000100)//beq
                 || (Instruction[31:26] == 6'b000101)//bne
                 || (Instruction[31:26] == 6'b000111)//bgtz
                 || (Instruction[31:26] == 6'b000010)//j
                 )?0:1;//���������г���ָ���⣬����Ҫд�Ĵ���
assign MemorIOtoReg = (Instruction[31:26] == 6'b100011)?1:0;//��ָ��Ϊlwʱ��Ҫ��1����ʾд��Ĵ������������Դ洢��Ԫ
assign Memorywrite = (Instruction[31:26] == 6'b101011)?1:0;
assign rtORrd = ((Instruction[31:26] == 6'b001000)//addi
                || (Instruction[31:26] == 6'b001001)//addiu
                || (Instruction[31:26] == 6'b001100)//andi
                || (Instruction[31:26] == 6'b001101)//ori
                || (Instruction[31:26] == 6'b001110)//xori
                || (Instruction[31:26] == 6'b001011)//sltiu
                || (Instruction[31:26] == 6'b001111)//lui
                || (Instruction[31:26] == 6'b100011)//lw
                )?1:0;//��ָ��Ϊ����ָ��ʱ����1��ʾд��rt�Ĵ���
assign slttu = ((Instruction[31:26] == 6'b0 && Instruction[5:0] == 6'b101010)//slt
                || (Instruction[31:26] == 6'b0 && Instruction[5:0] == 6'b101011)//sltu
                ||(Instruction[31:26] == 6'b001011)//sltiu
                )?1:0;//Ϊ����ָ��ʱ��1
//ALU_op����
always @(*) begin
    if(Instruction[31:26] == 6'b0)begin//r��ָ�����
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
//B_Sel����
//���ݸ�ִ�е�Ԫ��B������Ķ�·ѡ��,00��ʾ�Ĵ�����01��ʾ������,11��ʾ0
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
