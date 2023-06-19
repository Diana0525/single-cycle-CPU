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
input [31:0]Sign_Ext,//符号扩展输入
input [31:0]j_Sign_Ext,//j jal的扩展信号,废弃
input [5:0]opcode,//取指单元取出的指令中蕴含的操作码
input [5:0]opcode_function,//r型指令的末尾六位，代表不同的r型指令
input [4:0]shamt,//移位指令输入的位移量
input [2:0]ALU_op,//来自控制单元，八种ALU_op
input [31:0]PC_plus4,
input slttu,//slt or sltu
//input [1:0]A_Sel,//A端输入的多路选择
input [1:0]B_Sel,//B端输入的多路选择,0表示寄存器，1表示立即数
output Zero,//为1表示运算结果为0
output Zero_bgtz,//bgtz的标志位，为1表示rs>0
output [31:0]ALU_result,//输出32位运算结果
output [31:0]PC_result//输出指令地址的运算结果
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
wire [2:0]move_choice;//三种移动指令的选择
assign move_choice = opcode_function[2:0];
assign A_data = read_data_1;
assign B_data = S_data;
assign ALU_result = (slttu == 0)?result:s_result;
assign Zero = (result == 32'h00000000 && ALU_op == COMPARE)?1'b1:1'b0;//比较运算结果出现0，则置1
assign Zero_bgtz = (opcode == 6'b000111 && A_data[31] == 0)?1'b1:1'b0;//Zero_bgtz指令时，且最高位为0，表示为正的时候，置1
assign PC_result = PC_plus4+{Sign_Ext[29:0],2'b00};
//B端三路选择器，寄存器、符号扩展或0(bgtz）指令用到
always @(*)begin
    case(B_Sel)
        2'b00:S_data = read_data_2;
        2'b01:S_data = Sign_Ext;
        2'b11:S_data = 32'h0; 
    endcase
end
//基本运算执行
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
//移位指令执行
always @(*) begin
    if(ALU_op == MOVE && opcode == 6'b0)begin//R型指令中的三种位移运算
        case(move_choice)
            3'b000:result = B_data << shamt;//逻辑左移,sll
            3'b010:result = B_data >> shamt;//逻辑右移,srl
            3'b011:result = $signed(B_data)>>> shamt;//算术右移,sra
            3'b100:result = B_data << A_data;//sllv
            3'b110:result = B_data >> A_data;//srlv
            3'b111:result = $signed(B_data)>>>A_data; //srav
            default:result = B_data;
        endcase
    end
    if(ALU_op == MOVE && opcode != 6'b0 && B_Sel == 1'b1)begin //需要移动且不是r型指令且B端输入立即数的的只能是lui
        result = (B_data << 16 )&32'hFFFF0000;
    end
    if(ALU_op == COMPARE && slttu )begin //表明是需要比较的slt类型指令，B_Sel决定B_data是寄存器还是立即数
        if(opcode_function == 6'b101010 && A_data[31] == 1'b1 && B_data[31] == 1'b0)begin//有符号数比较,前面是负数后面是正数
            s_result = 1;
        end
        else if(opcode_function == 6'b101010 && A_data[31] == 1'b0 && B_data[31] == 1'b1)begin//有符号数比较,前面是正数后面是负数
            s_result = 0;
        end
        else begin
            slt_data = A_data - B_data;
            s_result = (slt_data[31] == 1)?1:0;
        end
        
    end
end

endmodule
