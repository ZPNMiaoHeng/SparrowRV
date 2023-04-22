`include "defines.v"
module plic (
	input clk,
	input rst_n,

    //ICB Slave sram
    input  wire                 plic_icb_cmd_valid,//cmd有效
    output wire                 plic_icb_cmd_ready,//cmd准备好
    input  wire [`MemAddrBus]   plic_icb_cmd_addr ,//cmd地址
    input  wire                 plic_icb_cmd_read ,//cmd读使能
    input  wire [`MemBus]       plic_icb_cmd_wdata,//cmd写数据
    input  wire [3:0]           plic_icb_cmd_wmask,//cmd写选通
    output reg                  plic_icb_rsp_valid,//rsp有效
    input  wire                 plic_icb_rsp_ready,//rsp准备好
    output wire                 plic_icb_rsp_err  ,//rsp错误
    output reg  [`MemBus]       plic_icb_rsp_rdata,//rsp读数据

    //全局中断源接口
    input  wire [15:0] plic_irq_port,

    //对接hart context硬件中断上下文0，与内核直接交互
    output wire core_ex_trap_valid_i,//外部中断请求
    output wire [4:0]core_ex_trap_id_i,//外部中断源ID
    input  wire core_ex_trap_ready_o,//外部中断响应
    input  wire core_ex_trap_cplet_o,//外部中断完成信号
    input  wire [4:0]core_ex_trap_cplet_id_o//外部中断完成的中断源ID

);
/*
PLIC
支持15个中断源(加上保留的中断源ID:0是16个)
支持1个中断硬件上下文(hart context0)
支持4个中断优先级(2bit)
支持4个中断阈值(2bit)
中断声明完成寄存器与标准PLIC不同，此寄存器可由内核直接操作并实现相关功能，且总线读操作不会产生任何影响。
*/
//中断源0-15优先级：0x000000-0x00007c
localparam PLIC_IP  = 28'h001000;//中断待定位IP 0-15
localparam PLIC_IE  = 28'h002000;//context0的中断源0-31使能位
localparam PLIC_ITH = 28'h200000;//context0的中断优先级阈值
localparam PLIC_CPC = 28'h200004;//context0的声明/完成
//定义寄存器组
reg [1:0]plic_prt[15:0];//中断源0-15优先级寄存器
reg [15:0]plic_ip;//只读，中断待定位IP 0-15
reg [15:0]plic_ie;//context0的中断源0-15使能位
reg [1:0]plic_ith;//context0的中断优先级阈值
reg [3:0]plic_cpc;//context0的中断声明完成寄存器

//ICB总线交互
wire icb_whsk = plic_icb_cmd_valid & ~plic_icb_cmd_read;//写握手
wire icb_rhsk = plic_icb_cmd_valid & plic_icb_cmd_read;//读握手
wire [27:0] waddr = plic_icb_cmd_addr[27:0];//写地址，屏蔽低位，字节选通替代
wire [27:0] raddr = plic_icb_cmd_addr[27:0];//读地址，屏蔽低位，译码执行部分替代
assign plic_icb_cmd_ready = 1'b1;
assign plic_icb_rsp_err   = 1'b0;
//读响应控制
always @(posedge clk or negedge rst_n)
if (~rst_n)
    plic_icb_rsp_valid <=1'b0;
else begin
    if (icb_rhsk)
        plic_icb_rsp_valid <=1'b1;
    else if (plic_icb_rsp_valid & plic_icb_rsp_ready)
        plic_icb_rsp_valid <=1'b0;
    else
        plic_icb_rsp_valid <= plic_icb_rsp_valid;
end
//总线写
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        plic_prt[0] <= 2'b0;
        plic_prt[1] <= 2'b0;
        plic_prt[2] <= 2'b0;
        plic_prt[3] <= 2'b0;
        plic_prt[4] <= 2'b0;
        plic_prt[5] <= 2'b0;
        plic_prt[6] <= 2'b0;
        plic_prt[7] <= 2'b0;
        plic_prt[8] <= 2'b0;
        plic_prt[9] <= 2'b0;
        plic_prt[10] <= 2'b0;
        plic_prt[11] <= 2'b0;
        plic_prt[12] <= 2'b0;
        plic_prt[13] <= 2'b0;
        plic_prt[14] <= 2'b0;
        plic_prt[15] <= 2'b0;
        plic_ie <= 16'h0;
        plic_ith <= 2'b0;
    end
    else begin
        if (icb_whsk) begin
            if (waddr<28'd16) begin //写中断源0-31优先级寄存器组
                plic_prt[waddr[3:0]] <= plic_icb_cmd_wdata[1:0];
            end
            else begin //写其他寄存器
                case (waddr)
                    PLIC_IE : begin
                        plic_ie <= plic_icb_cmd_wdata[15:0];
                    end
                    PLIC_ITH: begin
                        plic_ith <= plic_icb_cmd_wdata[1:0];
                    end
                endcase
            end
        end
    end
end

always @(posedge clk) begin
    if (icb_rhsk) begin
        if (raddr<28'd16) begin //读中断源0-31优先级寄存器组
            plic_icb_rsp_rdata <= {30'h0, plic_prt[raddr[3:0]]};
        end
        else begin //读其他寄存器
            case (raddr)
                PLIC_IP : plic_icb_rsp_rdata <= {16'h0, plic_ip};
                PLIC_IE : plic_icb_rsp_rdata <= {16'h0, plic_ie};
                PLIC_ITH: plic_icb_rsp_rdata <= {30'h0, plic_ith};
                PLIC_CPC: plic_icb_rsp_rdata <= {28'h0, plic_cpc};
                default: plic_icb_rsp_rdata <= 32'h0;
            endcase
        end
    end
end

wire icb_cpc_whsk = icb_whsk & (waddr==PLIC_CPC);
wire [3:0]icb_cpc_din = plic_icb_cmd_wdata[3:0];




endmodule