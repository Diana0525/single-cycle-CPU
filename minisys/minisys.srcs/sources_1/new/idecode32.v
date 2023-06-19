`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/10 11:02:21
// Design Name: 
// Module Name: idecode32
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


module idecode32(
input clock,
input reset,
input [31:0]Instruction,//从取指模块输入的指令
input [31:0]ALU_result,//从运算单元传回的写回值
input [31:0]read_from_mem,//从存储器读出的数据，在lw指令中使用
input [31:0]PC_plus4_jal,//来自取指单元，Jal专用PC+4，将存入31号寄存器中
input Jal,//高电平标志着是Jal指令操作
input jr,//来自控制单元，表示当前指令是jr
input RegWrite,//来自控制单元,写入寄存器信号
input MemorIOtoReg,//来自控制单元，从存储单元写入寄存器信号
input rtORrd,//来自控制单元，为1表示写入[20:16]rt,否则表示写入[15:11]rd
output [31:0]read_data_1,//输出的A1
output [31:0]read_data_2,//输出的A2
output [31:0]RA,//输出RA寄存器中的值
output [31:0]Sign_Ext,//输出的扩展信号
output [31:0]j_Sign_Ext,//j jal的扩展信号,废弃
output [4:0]debug_wb_rf_wnum,//写入的寄存器号
output [31:0]debug_wb_rf_wdata
);
reg [31:0] register[0:31];//32个32位宽的寄存器
reg [4:0]write_register_address;//要写入的寄存器编号
reg [31:0]write_data;//要写入的32位数据

wire [4:0]read_register_1_address;//要读的第一个寄存器编号rs
wire [4:0]read_register_2_address;//要读的第二个寄存器编号rt
wire [4:0]write_rt_address;//写入哪个寄存器的rt位置
wire [4:0]write_rd_address;//写入哪个寄存器的rd位置
wire [15:0]Instruction_immediate_value;//指令中的立即数
wire [5:0] opcode;//指令码
assign debug_wb_rf_wdata = write_data;
assign debug_wb_rf_wnum = write_register_address;
assign opcode = Instruction[31:26];
assign read_register_1_address = Instruction[25:21];
assign read_register_2_address = Instruction[20:16];
assign write_rt_address = Instruction[20:16];
assign write_rd_address = Instruction[15:11];
assign Instruction_immediate_value = Instruction[15:0];
assign RA = (jr)?register[read_register_1_address]:32'h0;

wire sign;//记录符号位的值
assign sign = Instruction_immediate_value[15];
assign Sign_Ext[31:0] = ((opcode == 6'b001100) || //andi
                    (opcode == 6'b001101) || //ori
                    (opcode == 6'b001110) //xori
                    )?{16'h0000,Instruction_immediate_value[15:0]}//0扩展
                    :{sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,Instruction_immediate_value[15:0]};//符号扩展
                    //0扩展
assign j_Sign_Ext[31:0] = ((opcode == 6'b000010) || //j
                    (opcode == 6'b000011)  //jal
                    )?{6'h0,Instruction[25:0]}:32'h0;
assign read_data_1 = register[read_register_1_address];//A1输出
assign read_data_2 = register[read_register_2_address];//A2输出
//指定不同指令下的目标寄存器
always @(*) begin
    if(Jal == 1'b1)begin//若当前指令是Jal
        write_register_address = 5'h1f;
    end
    else if(!Jal && rtORrd) begin
        write_register_address = write_rt_address;
    end
    else begin
        write_register_address = write_rd_address;
    end
end
//实现写入数据的多路选择器
always @(*) begin
    if(MemorIOtoReg)begin //lw指令,寄存器写入的内容来自存储器
        write_data = read_from_mem;
    end
    else if(Jal)begin//Jal指令，$31号寄存器写入PC+4，数据来自取指单元
        write_data = PC_plus4_jal;
    end
    else if(RegWrite)begin //不是lw和Jal指令,来自运算单元的内容写入寄存器
        write_data = ALU_result;
    end
    else begin
        write_data = 32'h0;
    end
end
//译码写入寄存器
integer i;
always @(posedge clock)begin
//    $strobe("write: %h \n ",write_data);
    
    if(reset)begin//复位则初始化寄存器组
        for(i=0;i<32;i=i+1) register[i] <= 0;
    end
    if (RegWrite)begin
        case(write_register_address)
            5'b0:register[0] <= 32'h0;//0号寄存器始终为0
            5'd1:register[1] <= write_data;
            5'd2:register[2] <= write_data;
            5'd3:register[3] <= write_data;
            5'd4:register[4] <= write_data;
            5'd5:register[5] <= write_data;
            5'd6:register[6] <= write_data;
            5'd7:register[7] <= write_data;
            5'd8:register[8] <= write_data;
            5'd9:register[9] <= write_data;
            5'd10:register[10] <= write_data;
            5'd11:register[11] <= write_data;
            5'd12:register[12] <= write_data;
            5'd13:register[13] <= write_data;
            5'd14:register[14] <= write_data;
            5'd15:register[15] <= write_data;
            5'd16:register[16] <= write_data;
            5'd17:register[17] <= write_data;
            5'd18:register[18] <= write_data;
            5'd19:register[19] <= write_data;
            5'd20:register[20] <= write_data;
            5'd21:register[21] <= write_data;
            5'd22:register[22] <= write_data;
            5'd23:register[23] <= write_data;
            5'd24:register[24] <= write_data;
            5'd25:register[25] <= write_data;
            5'd26:register[26] <= write_data;
            5'd27:register[27] <= write_data;
            5'd28:register[28] <= write_data;
            5'd29:register[29] <= write_data;
            5'd30:register[30] <= write_data;
            5'd31:register[31] <= write_data;
            default:register[0] <= 32'h0;
        endcase
    end
    
end


endmodule
