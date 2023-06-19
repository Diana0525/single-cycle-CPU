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
input [31:0]Instruction,//��ȡָģ�������ָ��
input [31:0]ALU_result,//�����㵥Ԫ���ص�д��ֵ
input [31:0]read_from_mem,//�Ӵ洢�����������ݣ���lwָ����ʹ��
input [31:0]PC_plus4_jal,//����ȡָ��Ԫ��Jalר��PC+4��������31�żĴ�����
input Jal,//�ߵ�ƽ��־����Jalָ�����
input jr,//���Կ��Ƶ�Ԫ����ʾ��ǰָ����jr
input RegWrite,//���Կ��Ƶ�Ԫ,д��Ĵ����ź�
input MemorIOtoReg,//���Կ��Ƶ�Ԫ���Ӵ洢��Ԫд��Ĵ����ź�
input rtORrd,//���Կ��Ƶ�Ԫ��Ϊ1��ʾд��[20:16]rt,�����ʾд��[15:11]rd
output [31:0]read_data_1,//�����A1
output [31:0]read_data_2,//�����A2
output [31:0]RA,//���RA�Ĵ����е�ֵ
output [31:0]Sign_Ext,//�������չ�ź�
output [31:0]j_Sign_Ext,//j jal����չ�ź�,����
output [4:0]debug_wb_rf_wnum,//д��ļĴ�����
output [31:0]debug_wb_rf_wdata
);
reg [31:0] register[0:31];//32��32λ��ļĴ���
reg [4:0]write_register_address;//Ҫд��ļĴ������
reg [31:0]write_data;//Ҫд���32λ����

wire [4:0]read_register_1_address;//Ҫ���ĵ�һ���Ĵ������rs
wire [4:0]read_register_2_address;//Ҫ���ĵڶ����Ĵ������rt
wire [4:0]write_rt_address;//д���ĸ��Ĵ�����rtλ��
wire [4:0]write_rd_address;//д���ĸ��Ĵ�����rdλ��
wire [15:0]Instruction_immediate_value;//ָ���е�������
wire [5:0] opcode;//ָ����
assign debug_wb_rf_wdata = write_data;
assign debug_wb_rf_wnum = write_register_address;
assign opcode = Instruction[31:26];
assign read_register_1_address = Instruction[25:21];
assign read_register_2_address = Instruction[20:16];
assign write_rt_address = Instruction[20:16];
assign write_rd_address = Instruction[15:11];
assign Instruction_immediate_value = Instruction[15:0];
assign RA = (jr)?register[read_register_1_address]:32'h0;

wire sign;//��¼����λ��ֵ
assign sign = Instruction_immediate_value[15];
assign Sign_Ext[31:0] = ((opcode == 6'b001100) || //andi
                    (opcode == 6'b001101) || //ori
                    (opcode == 6'b001110) //xori
                    )?{16'h0000,Instruction_immediate_value[15:0]}//0��չ
                    :{sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,Instruction_immediate_value[15:0]};//������չ
                    //0��չ
assign j_Sign_Ext[31:0] = ((opcode == 6'b000010) || //j
                    (opcode == 6'b000011)  //jal
                    )?{6'h0,Instruction[25:0]}:32'h0;
assign read_data_1 = register[read_register_1_address];//A1���
assign read_data_2 = register[read_register_2_address];//A2���
//ָ����ָͬ���µ�Ŀ��Ĵ���
always @(*) begin
    if(Jal == 1'b1)begin//����ǰָ����Jal
        write_register_address = 5'h1f;
    end
    else if(!Jal && rtORrd) begin
        write_register_address = write_rt_address;
    end
    else begin
        write_register_address = write_rd_address;
    end
end
//ʵ��д�����ݵĶ�·ѡ����
always @(*) begin
    if(MemorIOtoReg)begin //lwָ��,�Ĵ���д����������Դ洢��
        write_data = read_from_mem;
    end
    else if(Jal)begin//Jalָ�$31�żĴ���д��PC+4����������ȡָ��Ԫ
        write_data = PC_plus4_jal;
    end
    else if(RegWrite)begin //����lw��Jalָ��,�������㵥Ԫ������д��Ĵ���
        write_data = ALU_result;
    end
    else begin
        write_data = 32'h0;
    end
end
//����д��Ĵ���
integer i;
always @(posedge clock)begin
//    $strobe("write: %h \n ",write_data);
    
    if(reset)begin//��λ���ʼ���Ĵ�����
        for(i=0;i<32;i=i+1) register[i] <= 0;
    end
    if (RegWrite)begin
        case(write_register_address)
            5'b0:register[0] <= 32'h0;//0�żĴ���ʼ��Ϊ0
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
