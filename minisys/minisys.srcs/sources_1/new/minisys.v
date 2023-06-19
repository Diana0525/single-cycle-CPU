`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/09 13:41:39
// Design Name: 
// Module Name: minisys
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


module minisys(rst,clk
//,debug_wb_pc,debug_wb_rf_wen,debug_wb_rf_wnum,debug_wb_rf_wdata
,Instruction
//,clock
);
input rst;
input clk;
//output wire [31:0]debug_wb_pc;//查看pc的值
//output wire debug_wb_rf_wen;//寄存器堆的写使能
//output wire [4:0]debug_wb_rf_wnum;//查看寄存器堆的目标寄存器号
//output wire [31:0]debug_wb_rf_wdata;//写入寄存器的值
output wire [31:0]Instruction;
//output wire clock;//输入给各个系统的时钟
wire [31:0]debug_wb_pc;//查看pc的值
wire debug_wb_rf_wen;//寄存器堆的写使能
wire [4:0]debug_wb_rf_wnum;//查看寄存器堆的目标寄存器号
wire [31:0]debug_wb_rf_wdata;//写入寄存器的值

wire fpga_clk;// 100MHz, 板上时钟
wire clock;//输入给各个系统的时钟
cpuclock cpuclock(
.fpga_clk(clk),
.clock(clock)
);
wire [31:0]ALU_address;//来自执行单元，算出的跳转的地址
wire [31:0]RA;//来自译码单元，jr $ra指令用的地址
wire branch;
wire bne_branch;
wire jr;
wire jal;
wire beq;
wire bne;
wire jmp;
wire Zero_bgtz;
//wire [31:0]Instruction;
wire [31:0]rom_addr;
wire [31:0]PC_plus4_out;
wire [31:0]PC_plus4_jal;
wire [31:0]PC_result;
//取指模块
ifetc IFE(
.clock(clock),//时钟
.reset(rst),//复位信号，高电平有效
.ALU_address(PC_result),//来自执行单元，算出的跳转的地址
.j_address(PC_result),//直接得到的j的跳转地址
.RA(RA),//来自译码单元，jr $ra指令用的地址
//控制信号来自控制单元
.branch(branch),//高电平表示有分支
.bne_branch(bne_branch),
.jr(jr),//高电平表示是jr指令
.jal(jal),//高电平表示是jal指令
.beq(beq),
.bne(bne),
.jmp(jmp),
.Zero_bgtz(Zero_bgtz),
//输出信号
.Instruction(Instruction),//输出给下一模块的，已经取出的指令
.rom_addr(debug_wb_pc),//给指令存储器的取指地址
.PC_plus4_out(PC_plus4_out),//PC+4送执行单元
.PC_plus4_jal(PC_plus4_jal)//Jal专用PC+4
);
wire Zero;//来自执行单元，为1表示运算结果为0

wire RegWrite;
wire MemorIOtoReg;
wire Memorywrite;
wire rtORrd;
wire [2:0]ALU_op;
wire slttu;
wire [1:0]B_Sel;
//控制模块
control32 control(
.Instruction(Instruction),//来自取指单元的指令
.Zero(Zero),//来自执行单元，为1表示运算结果为0
.Zero_bgtz(Zero_bgtz),//来自执行单元，bgtz的标志位，为1表示rs>0
.branch(branch),//beq的分支信号，传递给取指单元，高电平表示有分支
.bne_branch(bne_branch),
.jr(jr),//传递给取指单元
.Jal(jal),//传递给译码单元、取指单元
.beq(beq),//传递给取指单元
.bne(bne),
.jmp(jmp),//传递给取指单元
.RegWrite(debug_wb_rf_wen),//传递给译码单元，当有数据要写入寄存器时，置1
.MemorIOtoReg(MemorIOtoReg),//传递给译码单元，当有来自存储器的数据要写入寄存器时，置1
.Memorywrite(Memorywrite),
.rtORrd(rtORrd),//传递给译码单元，控制写入rt还是rd,为1表示写入[20:16]rt,否则表示写入[15:11]rd
.ALU_op(ALU_op),//传递给执行单元，八种ALU_op
.slttu(slttu),//传递给执行单元，表示指令是slt or sltu
.B_Sel(B_Sel)//传递给执行单元，B端输入的多路选择,00表示寄存器，01表示立即数,11表示0
    );
wire [31:0]ALU_result;
wire [31:0]read_from_mem;
wire [31:0]read_data_1;//译码模块从指令存储器中取出的数据1
wire [31:0]read_data_2;//译码模块从指令存储器中取出的数据2
wire [31:0]Sign_Ext;//译码模块输出的扩展立即数
wire [31:0]j_Sign_Ext;
//译码模块
idecode32 idecode(
.clock(clock),
.reset(rst),
.Instruction(Instruction),//从取指模块输入的指令
.ALU_result(ALU_result),//从运算单元传回的写回值
.read_from_mem(read_from_mem),//从存储器读出的数据，在lw指令中使用
.PC_plus4_jal(PC_plus4_jal),//来自取指单元，Jal专用PC+4，将存入31号寄存器中
.Jal(jal),//高电平标志着是Jal指令操作
.jr(jr),
.RegWrite(debug_wb_rf_wen),//来自控制单元,写入寄存器信号
.MemorIOtoReg(MemorIOtoReg),//来自控制单元，从存储单元写入寄存器信号,lw
.rtORrd(rtORrd),//来自控制单元，为1表示写入[20:16]rt,否则表示写入[15:11]rd
.read_data_1(read_data_1),//输出的A1
.read_data_2(read_data_2),//输出的A2
.RA(RA),
.Sign_Ext(Sign_Ext),//输出的扩展信号
.j_Sign_Ext(j_Sign_Ext),//j jal的扩展信号
.debug_wb_rf_wnum(debug_wb_rf_wnum),//写入的寄存器号
.debug_wb_rf_wdata(debug_wb_rf_wdata)//写入寄存器的数据
);
//存储器模块
dmemory32 dmemory(
.read_data(read_from_mem),
.address(ALU_result),
.write_data(read_data_2),
.Memwrite(Memorywrite),
.clock(clock)
);
//执行模块
executs32 executs(
.read_data_1(read_data_1),//ALU A端输入
.read_data_2(read_data_2),//ALU_B端输入
.Sign_Ext(Sign_Ext),//符号扩展输入
.j_Sign_Ext(j_Sign_Ext),//j jal的扩展信号
.opcode(Instruction[31:26]),//取指单元取出的指令中蕴含的操作码
.opcode_function(Instruction[5:0]),//r型指令的末尾六位，代表不同的r型指令
.shamt(Instruction[10:6]),//移位指令输入的位移量
.ALU_op(ALU_op),//来自控制单元，八种ALU_op
.PC_plus4(PC_plus4_out),
.slttu(slttu),//slt or sltu
//input [1:0]A_Sel,//A端输入的多路选择
.B_Sel(B_Sel),//B端输入的多路选择,0表示寄存器，1表示立即数
.Zero(Zero),//为1表示运算结果为0
.Zero_bgtz(Zero_bgtz),//bgtz的标志位，为1表示rs>0
.ALU_result(ALU_result),//输出32位运算结果
.PC_result(PC_result)//算出的跳转地址,传送给取指单元取出下一条指令
);

endmodule
