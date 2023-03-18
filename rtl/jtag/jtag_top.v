`include "defines.v"

// JTAG顶层模块
module jtag_top (

    input wire clk,
    input wire jtag_rst_n,

    input wire jtag_pin_TCK,
    input wire jtag_pin_TMS,
    input wire jtag_pin_TDI,
    output wire jtag_pin_TDO,

    output wire reg_we_o,
    output wire[4:0] reg_addr_o,
    output wire[31:0] reg_wdata_o,
    input wire[31:0] reg_rdata_i,

    //ICB
    output wire                 jtag_icb_cmd_valid,//cmd有效
    input  wire                 jtag_icb_cmd_ready,//cmd准备好
    output wire [`MemAddrBus]   jtag_icb_cmd_addr ,//cmd地址
    output wire                 jtag_icb_cmd_read ,//cmd读使能
    output wire [`MemBus]       jtag_icb_cmd_wdata,//cmd写数据
    output wire [3:0]           jtag_icb_cmd_wmask,//cmd写选通
    input  wire                 jtag_icb_rsp_valid,//rsp有效
    output wire                 jtag_icb_rsp_ready,//rsp准备好
    input  wire                 jtag_icb_rsp_err  ,//rsp错误
    input  wire [`MemBus]       jtag_icb_rsp_rdata,//rsp读数据

    output wire halt_req_o,
    output wire reset_req_o

    );
localparam DMI_ADDR_BITS = 6;
localparam DMI_DATA_BITS = 32;
localparam DMI_OP_BITS = 2;
localparam DM_RESP_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;
localparam DTM_REQ_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;

//内存请求
wire req_valid_o;
wire mem_we_o;
wire[31:0] mem_addr_o;
wire[31:0] mem_wdata_o;
wire[31:0] mem_rdata_i;
wire[3:0] mem_sel_o;

assign jtag_icb_cmd_valid = req_valid_o;//请求内存
assign jtag_icb_cmd_addr  = {mem_addr_o[31:2], 2'b00};//屏蔽低位，字节选通替代
assign jtag_icb_cmd_read  = ~mem_we_o;//转换
assign jtag_icb_cmd_wdata = mem_wdata_o;
assign jtag_icb_cmd_wmask = mem_sel_o;
assign jtag_icb_rsp_ready = 1'b1;
assign mem_rdata_i = jtag_icb_rsp_rdata;



// jtag_driver输出信号
wire dtm_ack_o;
wire dtm_req_valid_o;
wire[DTM_REQ_BITS - 1:0] dtm_req_data_o;

// jtag_dm输出信号
wire dm_ack_o;
wire[DM_RESP_BITS-1:0] dm_resp_data_o;
wire dm_resp_valid_o;
wire dm_halt_req_o;
wire dm_reset_req_o;

jtag_driver #(
    .DMI_ADDR_BITS(DMI_ADDR_BITS),
    .DMI_DATA_BITS(DMI_DATA_BITS),
    .DMI_OP_BITS(DMI_OP_BITS)
) u_jtag_driver(
    .rst_n(jtag_rst_n),
    .jtag_TCK(jtag_pin_TCK),
    .jtag_TDI(jtag_pin_TDI),
    .jtag_TMS(jtag_pin_TMS),
    .jtag_TDO(jtag_pin_TDO),
    .dm_resp_i(dm_resp_valid_o),
    .dm_resp_data_i(dm_resp_data_o),
    .dtm_ack_o(dtm_ack_o),
    .dm_ack_i(dm_ack_o),
    .dtm_req_valid_o(dtm_req_valid_o),
    .dtm_req_data_o(dtm_req_data_o)
);

jtag_dm #(
    .DMI_ADDR_BITS(DMI_ADDR_BITS),
    .DMI_DATA_BITS(DMI_DATA_BITS),
    .DMI_OP_BITS(DMI_OP_BITS)
) u_jtag_dm(
    .clk(clk),
    .rst_n(jtag_rst_n),
    .dm_ack_o(dm_ack_o),
    .dtm_req_valid_i(dtm_req_valid_o),
    .dtm_req_data_i(dtm_req_data_o),
    .dtm_ack_i(dtm_ack_o),
    .dm_resp_data_o(dm_resp_data_o),
    .dm_resp_valid_o(dm_resp_valid_o),
    .dm_reg_we_o(reg_we_o),
    .dm_reg_addr_o(reg_addr_o),
    .dm_reg_wdata_o(reg_wdata_o),
    .dm_reg_rdata_i(reg_rdata_i),
    .dm_mem_we_o(mem_we_o),
    .dm_mem_addr_o(mem_addr_o),
    .dm_mem_wdata_o(mem_wdata_o),
    .dm_mem_rdata_i(mem_rdata_i),
    .dm_mem_sel_o(mem_sel_o),
    .req_valid_o(req_valid_o),
    .dm_halt_req_o(halt_req_o),
    .dm_reset_req_o(reset_req_o)
);

endmodule

/*
"jtag_top.v is licensed under Apache-2.0 (http://www.apache.org/licenses/LICENSE-2.0)
   by Blue Liang, liangkangnan@163.com.
*/