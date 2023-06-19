`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/09 15:55:37
// Design Name: 
// Module Name: executs32
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


module executs32(
input [31:0]read_data_1,//rs
input [31:0]read_data_2,//rt
input [31:0]Sign_Ext,//������չ����
input [31:0]j_Sign_Ext,//j jal����չ�ź�,����
input [5:0]opcode,//ȡָ��Ԫȡ����ָ�����̺��Ĳ�����
input [5:0]opcode_function,//r��ָ���ĩβ��λ������ͬ��r��ָ��
input [4:0]shamt,//��λָ�������λ����
input [2:0]ALU_op,//���Կ��Ƶ�Ԫ������ALU_op
input [31:0]PC_plus4,
input slttu,//slt or sltu
//input [1:0]A_Sel,//A������Ķ�·ѡ��
input [1:0]B_Sel,//B������Ķ�·ѡ��,0��ʾ�Ĵ�����1��ʾ������
output Zero,//Ϊ1��ʾ������Ϊ0
output Zero_bgtz,//bgtz�ı�־λ��Ϊ1��ʾrs>0
output [31:0]ALU_result,//���32λ������
output [31:0]PC_result//���ָ���ַ��������
);
reg [31:0]result;
reg [31:0]s_result;
parameter ADD = 3'b000,
            SUB = 3'b001,
            AND = 3'b010,
            OR = 3'b011,
            XOR = 3'b100,
            NOR =3'b101,
            MOVE = 3'b110,
            COMPARE = 3'b111;
wire [31:0]A_data;
wire [31:0]B_data;
reg [31:0]S_data;
reg [31:0]slt_data;
wire [2:0]move_choice;//�����ƶ�ָ���ѡ��
assign move_choice = opcode_function[2:0];
assign A_data = read_data_1;
assign B_data = S_data;
assign ALU_result = (slttu == 0)?result:s_result;
assign Zero = (result == 32'h00000000 && ALU_op == COMPARE)?1'b1:1'b0;//�Ƚ�����������0������1
assign Zero_bgtz = (opcode == 6'b000111 && A_data[31] == 0)?1'b1:1'b0;//Zero_bgtzָ��ʱ�������λΪ0����ʾΪ����ʱ����1
assign PC_result = PC_plus4+{Sign_Ext[29:0],2'b00};
//B����·ѡ�������Ĵ�����������չ��0(bgtz��ָ���õ�
always @(*)begin
    case(B_Sel)
        2'b00:S_data = read_data_2;
        2'b01:S_data = Sign_Ext;
        2'b11:S_data = 32'h0; 
    endcase
end
//��������ִ��
always @(*)begin
    case(ALU_op)
        ADD:result = A_data + B_data;
        SUB:result = A_data - B_data;
        AND:result = A_data & B_data;
        OR:result = A_data | B_data;
        XOR:result = A_data ^ B_data;
        NOR:result = ~(A_data | B_data);
        COMPARE:result = A_data - B_data;
    endcase
end
//��λָ��ִ��
always @(*) begin
    if(ALU_op == MOVE && opcode == 6'b0)begin//R��ָ���е�����λ������
        case(move_choice)
            3'b000:result = B_data << shamt;//�߼�����,sll
            3'b010:result = B_data >> shamt;//�߼�����,srl
            3'b011:result = $signed(B_data)>>> shamt;//��������,sra
            3'b100:result = B_data << A_data;//sllv
            3'b110:result = B_data >> A_data;//srlv
            3'b111:result = $signed(B_data)>>>A_data; //srav
            default:result = B_data;
        endcase
    end
    if(ALU_op == MOVE && opcode != 6'b0 && B_Sel == 1'b1)begin //��Ҫ�ƶ��Ҳ���r��ָ����B�������������ĵ�ֻ����lui
        result = (B_data << 16 )&32'hFFFF0000;
    end
    if(ALU_op == COMPARE && slttu )begin //��������Ҫ�Ƚϵ�slt����ָ�B_Sel����B_data�ǼĴ�������������
        if(opcode_function == 6'b101010 && A_data[31] == 1'b1 && B_data[31] == 1'b0)begin//�з������Ƚ�,ǰ���Ǹ�������������
            s_result = 1;
        end
        else if(opcode_function == 6'b101010 && A_data[31] == 1'b0 && B_data[31] == 1'b1)begin//�з������Ƚ�,ǰ�������������Ǹ���
            s_result = 0;
        end
        else begin
            slt_data = A_data - B_data;
            s_result = (slt_data[31] == 1)?1:0;
        end
        
    end
end

endmodule
