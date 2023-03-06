`include "defines.v"
module sram (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

    //AXI4-Lite总线接口 Slave
    //AW写地址
    input wire [`MemAddrBus]    sram_axi_awaddr ,//写地址
    input wire                  sram_axi_awvalid,//写地址有效
    output reg                  sram_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        sram_axi_wdata  ,//写数据
    input wire [3:0]            sram_axi_wstrb  ,//写数据选通
    input wire                  sram_axi_wvalid ,//写数据有效
    output reg                  sram_axi_wready ,//写数据准备好
    //AR读地址
    input wire [`MemAddrBus]    sram_axi_araddr ,//读地址
    input wire                  sram_axi_arvalid,//读地址有效
    output reg                  sram_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        sram_axi_rdata  ,//读数据
    output reg                  sram_axi_rvalid ,//读数据有效
    input wire                  sram_axi_rready //读数据准备好
	
);


//AXI4L总线交互
reg [clogb2(`SRamSize-1)-1:0]addr;
reg we,en;
reg [3:0] wem;
wire [`MemBus]dout;
reg [`MemBus]din;
wire axi_whsk = sram_axi_awvalid & sram_axi_wvalid;//写通道握手
wire axi_rhsk = sram_axi_arvalid & (~sram_axi_rvalid | (sram_axi_rvalid & sram_axi_rready)) & ~axi_whsk;//读通道握手,没有读响应或读响应握手成功

localparam [clogb2(`SRamSize-1)-1:0] addr_zero0 = 0;

always @(posedge clk or negedge rst_n)//读响应控制
if (~rst_n)
    sram_axi_rvalid <=1'b0;
else begin
    if (axi_rhsk)
        sram_axi_rvalid <=1'b1;
    else if (sram_axi_rvalid & sram_axi_rready)
        sram_axi_rvalid <=1'b0;
    else
        sram_axi_rvalid <= sram_axi_rvalid;
end

always @(*) begin
    sram_axi_awready = axi_whsk;//写地址数据同时准备好
    sram_axi_wready = axi_whsk;//写地址数据同时准备好
    sram_axi_rdata = dout;//读数据
    sram_axi_arready = axi_rhsk;//读地址握手
    if(axi_whsk) begin//写握手
        addr = sram_axi_awaddr[clogb2(`SRamSize-1)+1:2];
        we = 1;
    end
    else begin
        if (axi_rhsk) begin//读握手
            addr = sram_axi_araddr[clogb2(`SRamSize-1)+1:2];
            we = 0;
        end
        else begin
            addr = 0;
            we = 0;
        end
    end
    din = sram_axi_wdata;
    en = axi_whsk | axi_rhsk;//握手成功，使能存储器
    wem = sram_axi_wstrb;
end

//RTL SRAM
parameter RAM_WIDTH = 32;//RAM数据位宽
parameter RAM_DEPTH = `SRamSize;//RAM深度
reg [7:0] BRAM0 [0:RAM_DEPTH-1];
reg [7:0] BRAM1 [0:RAM_DEPTH-1];
reg [7:0] BRAM2 [0:RAM_DEPTH-1];
reg [7:0] BRAM3 [0:RAM_DEPTH-1];
wire [7:0] dout0;
wire [7:0] dout1;
wire [7:0] dout2;
wire [7:0] dout3;
reg [RAM_WIDTH-1:0] addr_r0;
reg [RAM_WIDTH-1:0] addr_r1;
reg [RAM_WIDTH-1:0] addr_r2;
reg [RAM_WIDTH-1:0] addr_r3;
/*
always @(posedge clk)
    if (en) begin
        if(we&wem[0])
            BRAM0[addr] <= din[7:0];
        if(we&wem[1])
            BRAM1[addr] <= din[15:8];
        if(we&wem[2])
            BRAM2[addr] <= din[23:16];
        if(we&wem[3])
            BRAM3[addr] <= din[31:24];
        addr_r <= addr;
    end

assign dout = {BRAM3[addr_r], BRAM2[addr_r], BRAM1[addr_r], BRAM0[addr_r]};
*/
always @(posedge clk)
    if (en) begin
        if(we&wem[0])
            BRAM0[addr] <= din[7:0];
        addr_r0 <= addr;
    end
assign dout0 =  BRAM0[addr_r0];

always @(posedge clk)
    if (en) begin
        if(we&wem[1])
            BRAM1[addr] <= din[15:8];
        addr_r1 <= addr;
    end
assign dout1 =  BRAM1[addr_r1];

always @(posedge clk)
    if (en) begin
        if(we&wem[2])
            BRAM2[addr] <= din[23:16];
        addr_r2 <= addr;
    end
assign dout2 =  BRAM2[addr_r2];

always @(posedge clk)
    if (en) begin
        if(we&wem[3])
            BRAM3[addr] <= din[31:24];
        addr_r3 <= addr;
    end
assign dout3 =  BRAM3[addr_r3];

assign dout = {dout3, dout2, dout1, dout0};

function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction

endmodule