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
//output wire [31:0]debug_wb_pc;//�鿴pc��ֵ
//output wire debug_wb_rf_wen;//�Ĵ����ѵ�дʹ��
//output wire [4:0]debug_wb_rf_wnum;//�鿴�Ĵ����ѵ�Ŀ��Ĵ�����
//output wire [31:0]debug_wb_rf_wdata;//д��Ĵ�����ֵ
output wire [31:0]Instruction;
//output wire clock;//���������ϵͳ��ʱ��
wire [31:0]debug_wb_pc;//�鿴pc��ֵ
wire debug_wb_rf_wen;//�Ĵ����ѵ�дʹ��
wire [4:0]debug_wb_rf_wnum;//�鿴�Ĵ����ѵ�Ŀ��Ĵ�����
wire [31:0]debug_wb_rf_wdata;//д��Ĵ�����ֵ

wire fpga_clk;// 100MHz, ����ʱ��
wire clock;//���������ϵͳ��ʱ��
cpuclock cpuclock(
.fpga_clk(clk),
.clock(clock)
);
wire [31:0]ALU_address;//����ִ�е�Ԫ���������ת�ĵ�ַ
wire [31:0]RA;//�������뵥Ԫ��jr $raָ���õĵ�ַ
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
//ȡָģ��
ifetc IFE(
.clock(clock),//ʱ��
.reset(rst),//��λ�źţ��ߵ�ƽ��Ч
.ALU_address(PC_result),//����ִ�е�Ԫ���������ת�ĵ�ַ
.j_address(PC_result),//ֱ�ӵõ���j����ת��ַ
.RA(RA),//�������뵥Ԫ��jr $raָ���õĵ�ַ
//�����ź����Կ��Ƶ�Ԫ
.branch(branch),//�ߵ�ƽ��ʾ�з�֧
.bne_branch(bne_branch),
.jr(jr),//�ߵ�ƽ��ʾ��jrָ��
.jal(jal),//�ߵ�ƽ��ʾ��jalָ��
.beq(beq),
.bne(bne),
.jmp(jmp),
.Zero_bgtz(Zero_bgtz),
//����ź�
.Instruction(Instruction),//�������һģ��ģ��Ѿ�ȡ����ָ��
.rom_addr(debug_wb_pc),//��ָ��洢����ȡָ��ַ
.PC_plus4_out(PC_plus4_out),//PC+4��ִ�е�Ԫ
.PC_plus4_jal(PC_plus4_jal)//Jalר��PC+4
);
wire Zero;//����ִ�е�Ԫ��Ϊ1��ʾ������Ϊ0

wire RegWrite;
wire MemorIOtoReg;
wire Memorywrite;
wire rtORrd;
wire [2:0]ALU_op;
wire slttu;
wire [1:0]B_Sel;
//����ģ��
control32 control(
.Instruction(Instruction),//����ȡָ��Ԫ��ָ��
.Zero(Zero),//����ִ�е�Ԫ��Ϊ1��ʾ������Ϊ0
.Zero_bgtz(Zero_bgtz),//����ִ�е�Ԫ��bgtz�ı�־λ��Ϊ1��ʾrs>0
.branch(branch),//beq�ķ�֧�źţ����ݸ�ȡָ��Ԫ���ߵ�ƽ��ʾ�з�֧
.bne_branch(bne_branch),
.jr(jr),//���ݸ�ȡָ��Ԫ
.Jal(jal),//���ݸ����뵥Ԫ��ȡָ��Ԫ
.beq(beq),//���ݸ�ȡָ��Ԫ
.bne(bne),
.jmp(jmp),//���ݸ�ȡָ��Ԫ
.RegWrite(debug_wb_rf_wen),//���ݸ����뵥Ԫ����������Ҫд��Ĵ���ʱ����1
.MemorIOtoReg(MemorIOtoReg),//���ݸ����뵥Ԫ���������Դ洢��������Ҫд��Ĵ���ʱ����1
.Memorywrite(Memorywrite),
.rtORrd(rtORrd),//���ݸ����뵥Ԫ������д��rt����rd,Ϊ1��ʾд��[20:16]rt,�����ʾд��[15:11]rd
.ALU_op(ALU_op),//���ݸ�ִ�е�Ԫ������ALU_op
.slttu(slttu),//���ݸ�ִ�е�Ԫ����ʾָ����slt or sltu
.B_Sel(B_Sel)//���ݸ�ִ�е�Ԫ��B������Ķ�·ѡ��,00��ʾ�Ĵ�����01��ʾ������,11��ʾ0
    );
wire [31:0]ALU_result;
wire [31:0]read_from_mem;
wire [31:0]read_data_1;//����ģ���ָ��洢����ȡ��������1
wire [31:0]read_data_2;//����ģ���ָ��洢����ȡ��������2
wire [31:0]Sign_Ext;//����ģ���������չ������
wire [31:0]j_Sign_Ext;
//����ģ��
idecode32 idecode(
.clock(clock),
.reset(rst),
.Instruction(Instruction),//��ȡָģ�������ָ��
.ALU_result(ALU_result),//�����㵥Ԫ���ص�д��ֵ
.read_from_mem(read_from_mem),//�Ӵ洢�����������ݣ���lwָ����ʹ��
.PC_plus4_jal(PC_plus4_jal),//����ȡָ��Ԫ��Jalר��PC+4��������31�żĴ�����
.Jal(jal),//�ߵ�ƽ��־����Jalָ�����
.jr(jr),
.RegWrite(debug_wb_rf_wen),//���Կ��Ƶ�Ԫ,д��Ĵ����ź�
.MemorIOtoReg(MemorIOtoReg),//���Կ��Ƶ�Ԫ���Ӵ洢��Ԫд��Ĵ����ź�,lw
.rtORrd(rtORrd),//���Կ��Ƶ�Ԫ��Ϊ1��ʾд��[20:16]rt,�����ʾд��[15:11]rd
.read_data_1(read_data_1),//�����A1
.read_data_2(read_data_2),//�����A2
.RA(RA),
.Sign_Ext(Sign_Ext),//�������չ�ź�
.j_Sign_Ext(j_Sign_Ext),//j jal����չ�ź�
.debug_wb_rf_wnum(debug_wb_rf_wnum),//д��ļĴ�����
.debug_wb_rf_wdata(debug_wb_rf_wdata)//д��Ĵ���������
);
//�洢��ģ��
dmemory32 dmemory(
.read_data(read_from_mem),
.address(ALU_result),
.write_data(read_data_2),
.Memwrite(Memorywrite),
.clock(clock)
);
//ִ��ģ��
executs32 executs(
.read_data_1(read_data_1),//ALU A������
.read_data_2(read_data_2),//ALU_B������
.Sign_Ext(Sign_Ext),//������չ����
.j_Sign_Ext(j_Sign_Ext),//j jal����չ�ź�
.opcode(Instruction[31:26]),//ȡָ��Ԫȡ����ָ�����̺��Ĳ�����
.opcode_function(Instruction[5:0]),//r��ָ���ĩβ��λ������ͬ��r��ָ��
.shamt(Instruction[10:6]),//��λָ�������λ����
.ALU_op(ALU_op),//���Կ��Ƶ�Ԫ������ALU_op
.PC_plus4(PC_plus4_out),
.slttu(slttu),//slt or sltu
//input [1:0]A_Sel,//A������Ķ�·ѡ��
.B_Sel(B_Sel),//B������Ķ�·ѡ��,0��ʾ�Ĵ�����1��ʾ������
.Zero(Zero),//Ϊ1��ʾ������Ϊ0
.Zero_bgtz(Zero_bgtz),//bgtz�ı�־λ��Ϊ1��ʾrs>0
.ALU_result(ALU_result),//���32λ������
.PC_result(PC_result)//�������ת��ַ,���͸�ȡָ��Ԫȡ����һ��ָ��
);

endmodule
