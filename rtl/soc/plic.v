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
    output wire [`MemBus]       plic_icb_rsp_rdata//rsp读数据
	

);
/*
PLIC
支持15个中断源
支持1个中断硬件上下文
支持4个中断优先级
支持4个中断阈值
*/

//ICB总线交互
// 总线接口 写
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin

    end 
    else begin
        if (we_i == 1'b1) begin
            case (waddr_i)
                TIMER_CTRL: begin

                end
                TIMER_CMPO: begin

                end
                TIMER_TCOF :begin
                    timer_of <= data_i[31:16];
                end
            endcase
        end 
        else begin
        end
    end
end

// 总线接口 读
always @ (posedge clk) begin
    if (rd_i == 1'b1) begin
        case (raddr_i)
            TIMER_CTRL: begin
                data_o <= ;
            end
            TIMER_CMPO: begin
                data_o <= ;
            end
            TIMER_CAPI: begin
                data_o <= ;
            end
            TIMER_TCOF: begin
                data_o <= ;
            end
            default: begin
                data_o <= 32'h0;
            end
        endcase
    end
    else begin
        data_o <= data_o;
    end
end

endmodule