`include "defines.v"
module sd_reader (
	input clk,
	input rst_n,

    //ICB Slave
    input  wire                 sdrd_icb_cmd_valid,//cmd有效
    output wire                 sdrd_icb_cmd_ready,//cmd准备好
    input  wire [`MemAddrBus]   sdrd_icb_cmd_addr ,//cmd地址
    input  wire                 sdrd_icb_cmd_read ,//cmd读使能
    input  wire [`MemBus]       sdrd_icb_cmd_wdata,//cmd写数据
    input  wire [3:0]           sdrd_icb_cmd_wmask,//cmd写选通
    output reg                  sdrd_icb_rsp_valid,//rsp有效
    input  wire                 sdrd_icb_rsp_ready,//rsp准备好
    output wire                 sdrd_icb_rsp_err  ,//rsp错误
    output reg  [`MemBus]       sdrd_icb_rsp_rdata,//rsp读数据

    //SD/TF卡接口
    output wire         sd_clk,
    inout               sd_cmd,
    input  wire         sd_dat0 
);
/*
SD/TF卡接口
仅使用1-bit SD模式，包含了clk,cmd,dat0引脚。
dat 1-3用不到，必须外部上拉到高电平。
*/
wire icb_whsk = sdrd_icb_cmd_valid & ~sdrd_icb_cmd_read;//写握手
wire icb_rhsk = sdrd_icb_cmd_valid & sdrd_icb_cmd_read;//读握手
wire [27:0] raddr = sdrd_icb_cmd_addr[27:2];//读地址，屏蔽低2位，[10:2]对应512B扇区[0,511]
assign sdrd_icb_cmd_ready = 1'b1;
assign sdrd_icb_rsp_err   = 1'b0;
//读响应控制
always @(posedge clk or negedge rst_n)
if (~rst_n)
    sdrd_icb_rsp_valid <=1'b0;
else begin
    if (icb_rhsk)
        sdrd_icb_rsp_valid <=1'b1;
    else if (sdrd_icb_rsp_valid & sdrd_icb_rsp_ready)
        sdrd_icb_rsp_valid <=1'b0;
    else
        sdrd_icb_rsp_valid <= sdrd_icb_rsp_valid;
end
//总线写
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sdrd_prt[1] <= 2'b0;

    end
    else begin
        if (icb_whsk) begin

        end
    end
end

always @(posedge clk) begin
    if (icb_rhsk) begin
        case (raddr)
            28'h0   : sdrd_icb_rsp_rdata <= 32'h0;

            default: sdrd_icb_rsp_rdata <= 32'h0;
        endcase
    end
end







sd_reader #(
    .CLK_DIV(CLK_DIV),
    .SIMULATE(0)
) inst_sd_reader (
    .rst_n     (rst_n),
    .clk       (clk),

    .sdclk     (sd_clk),
    .sdcmd     (sd_cmd),
    .sddat0    (sd_dat0),

    .card_stat (card_stat),
    .card_type (card_type),

    .rstart    (rstart),
    .rsector   (rsector),
    .rbusy     (rbusy),
    .rdone     (rdone),

    .outen     (outen),
    .outaddr   (outaddr),
    .outbyte   (outbyte)
);

endmodule

