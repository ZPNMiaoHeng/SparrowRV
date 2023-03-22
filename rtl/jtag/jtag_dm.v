

module jtag_dm #(
    parameter DMI_ADDR_BITS = 6,
    parameter DMI_DATA_BITS = 32,
    parameter DMI_OP_BITS = 2,
    parameter DM_RESP_BITS = 40,
    parameter DTM_REQ_BITS = 40
)(
    //时钟和复位
    input  wire clk,
    input  wire rst_n,
    
    //DMI
    //dm->dtm
    output wire dm_ack_o,
    input  wire dtm_req_valid_i,
    input  wire [DTM_REQ_BITS-1:0] dtm_req_data_i,
    //dtm->dm
    input  wire dtm_ack_i,
    output wire [DM_RESP_BITS-1:0] dm_resp_data_o,
    output wire dm_resp_valid_o,

    //GPR访问接口
    output wire        dm_reg_we_o,
    output wire [4:0]  dm_reg_addr_o,
    output wire [31:0] dm_reg_wdata_o,
    input  wire [31:0] dm_reg_rdata_i,

    //system bus访问接口
    output wire        dm_mem_we_o,
    output wire [31:0] dm_mem_addr_o,
    output wire [31:0] dm_mem_wdata_o,
    input  wire [31:0] dm_mem_rdata_i,
    output wire [3:0]  dm_mem_sel_o,
    output wire req_valid_o,//访问请求

    output wire dm_halt_req_o,
    output wire dm_reset_req_o

);

localparam SHIFT_REG_BITS = DTM_REQ_BITS;

// DM模块寄存器
reg [31:0] dcsr;
reg [31:0] dmstatus;
reg [31:0] dmcontrol;
reg [31:0] hartinfo;
reg [2:0]  abstractcs_cmderr;//abstractcs[10:8]
reg [31:0] data0;
reg sbcs_sbreadonaddr;//sbcs[20]
reg [2:0] sbcs_sbaccess;//sbcs[19:17]
reg sbcs_sbautoincrement;//sbcs[16]
reg sbcs_sbreadondata;//sbcs[15]
reg [31:0] sbaddress0;


// DM模块寄存器地址
localparam DCSR       = 16'h7b0;
localparam DMSTATUS   = 6'h11;
localparam DMCONTROL  = 6'h10;
localparam HARTINFO   = 6'h12;
localparam ABSTRACTCS = 6'h16;
localparam COMMAND    = 6'h17;
localparam DATA0      = 6'h04;
localparam SBCS       = 6'h38;
localparam SBADDRESS0 = 6'h39;
localparam SBDATA0    = 6'h3C;
localparam DPC        = 16'h7b1;

localparam OP_SUCC    = 2'b00;//DMI_OP读，00操作完成，01保留，10上一个操作失败，11上一个操作未完成

//状态机
reg[2:0] state;//状态寄存器
localparam STATE_IDLE = 3'b001;//空闲，随时接收DMI
localparam STATE_EXE  = 3'b010;//根据DMI的命令做相应的事
localparam STATE_END  = 3'b100;//结束一次操作

//DTM_OP行为
localparam DTM_OP_NOP   = 2'b00;
localparam DTM_OP_READ  = 2'b01;
localparam DTM_OP_WRITE = 2'b10;


reg[31:0] dmi_rsp_data;
reg dm_reg_we;
reg[4:0] dm_reg_addr;
reg[31:0] dm_reg_wdata;
reg dm_mem_we;
reg[31:0] dm_mem_addr;
reg[31:0] dm_mem_wdata;
reg[31:0] dm_mem_rdata;
reg dm_halt_req;
reg dm_reset_req;
reg need_resp;
reg is_read_reg;
wire rx_valid;
wire[DTM_REQ_BITS-1:0] rx_data;//dtm->dm，从dmi传来的数据
reg[DTM_REQ_BITS-1:0] rx_data_r;//存储dmi传来的数据，用于进一步处理

wire[3:0] dm_mem_sel = (sbcs_sbaccess == 3'd0)? 4'b0001:
                        (sbcs_sbaccess == 3'd1)? 4'b0011:
                        4'b1111;
wire[2:0] address_inc_step = (sbcs_sbaccess == 3'd0)? 3'd1:
                                (sbcs_sbaccess == 3'd1)? 3'd2:
                                3'd4;
wire[31:0] sbaddress0_next = sbaddress0 + {29'h0, address_inc_step};
wire[DM_RESP_BITS-1:0] dm_resp_data;

wire[DMI_OP_BITS-1:0] dmi_op = rx_data_r[DMI_OP_BITS-1:0];//dmi的op
wire[DMI_DATA_BITS-1:0] dmi_data = rx_data_r[DMI_DATA_BITS+DMI_OP_BITS-1:DMI_OP_BITS];//dmi的数据
wire[DMI_ADDR_BITS-1:0] dmi_addr = rx_data_r[DTM_REQ_BITS-1:DMI_DATA_BITS+DMI_OP_BITS];//dmi的地址

wire req_sys_bus = ~(dmi_addr == DMSTATUS);

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dm_mem_we <= 1'b0;
        dm_reg_we <= 1'b0;
        dm_halt_req <= 1'b0;
        dm_reset_req <= 1'b0;
        dm_mem_addr <= 32'h0;
        dm_reg_addr <= 5'h0;
        sbaddress0 <= 32'h0;
        dcsr <= 32'h0;
        hartinfo <= 32'h0;
        sbcs_sbreadonaddr <= 1'b0;//sbcs[20]
        sbcs_sbaccess <= 3'h2;//sbcs[19:17]
        sbcs_sbautoincrement <= 1'b0;//sbcs[16]
        sbcs_sbreadondata <= 1'b0;//sbcs[15]
        dmcontrol <= 32'h0;
        abstractcs_cmderr <= 3'h0;
        data0 <= 32'h0;
        dm_reg_wdata <= 32'h0;
        dm_mem_wdata <= 32'h0;
        dm_mem_rdata <= 32'h0;
        dmstatus <= 32'h430c82;
        is_read_reg <= 1'b0;
        dmi_rsp_data <= 32'h0;
        need_resp <= 1'b0;
        rx_data_r <= 0;
        state <= STATE_IDLE;
    end else begin
        case (state)
            STATE_IDLE: begin //空闲状态
                if (rx_valid) begin //接收到jtag_driver通过DMI传来的请求
                    rx_data_r <= rx_data; //锁存数据
                    state <= STATE_EXE; //状态转移到
                end
            end
            STATE_EXE: begin //根据DMI执行任务
                state <= STATE_END;
                need_resp <= 1'b1;
                case (dmi_op)
                    DTM_OP_READ: begin //读操作
                        case (dmi_addr)
                            DMSTATUS: begin
                                dmi_rsp_data <= dmstatus;
                            end
                            DMCONTROL: begin
                                dmi_rsp_data <= dmcontrol;
                            end
                            HARTINFO: begin
                                dmi_rsp_data <= hartinfo;
                            end
                            SBCS: begin
                                dmi_rsp_data <= {11'b0010_0000_000, sbcs_sbreadonaddr, sbcs_sbaccess, sbcs_sbautoincrement, sbcs_sbreadondata, 3'h0, 7'd32, 5'b00100};//sbcs = 32'h20040404;
                            end
                            ABSTRACTCS: begin
                                dmi_rsp_data <= {20'h1000, 1'b0, abstractcs_cmderr, 8'h03};
                            end
                            DATA0: begin
                                if (is_read_reg == 1'b1) begin //读GPR
                                    dmi_rsp_data <= dm_reg_rdata_i;
                                end else begin //读dcsr
                                    dmi_rsp_data <= data0;
                                end
                                is_read_reg <= 1'b0; //复位标记
                            end
                            SBDATA0: begin
                                dmi_rsp_data <= dm_mem_rdata;
                                if (sbcs_sbautoincrement == 1'b1) begin
                                    sbaddress0 <= sbaddress0_next;
                                end
                                if (sbcs_sbreadondata == 1'b1) begin
                                    dm_mem_addr <= sbaddress0_next;
                                end
                            end
                            default: begin
                                dmi_rsp_data <= {(DMI_DATA_BITS){1'b0}};
                            end
                        endcase
                    end

                    DTM_OP_WRITE: begin //写操作
                        dmi_rsp_data <= {(DMI_DATA_BITS){1'b0}};
                        case (dmi_addr)
                            DMCONTROL: begin
                                // reset DM module
                                if (dmi_data[0] == 1'b0) begin
                                    dcsr <= 32'hc0;
                                    dmstatus <= 32'h430c82;  // not halted, all running
                                    hartinfo <= 32'h0;
                                    sbcs_sbreadonaddr <= 1'b0;//sbcs[20]
                                    sbcs_sbaccess <= 3'h2;//sbcs[19:17]
                                    sbcs_sbautoincrement <= 1'b0;//sbcs[16]
                                    sbcs_sbreadondata <= 1'b0;//sbcs[15]
                                    abstractcs_cmderr <= 3'h0;
                                    dmcontrol <= dmi_data;
                                    dm_halt_req <= 1'b0;
                                    dm_reset_req <= 1'b0;
                                // DM is active
                                end else begin
                                    // we have only one hart
                                    dmcontrol <= (dmi_data & ~(32'h3fffc0)) | 32'h10000;
                                    // halt
                                    if (dmi_data[31] == 1'b1) begin
                                        dm_halt_req <= 1'b1;
                                        // clear ALLRUNNING ANYRUNNING and set ALLHALTED
                                        dmstatus <= {dmstatus[31:12], 4'h3, dmstatus[7:0]};
                                    // reset
                                    end else if (dmi_data[1] == 1'b1) begin
                                        dm_reset_req <= 1'b1;
                                        dm_halt_req <= 1'b0;
                                        dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                    // resume
                                    end else if (dm_halt_req == 1'b1 && dmi_data[30] == 1'b1) begin
                                        dm_halt_req <= 1'b0;
                                        // set ALLRUNNING ANYRUNNING and clear ALLHALTED
                                        dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                    end
                                end
                            end
                            COMMAND: begin //功能只有访问寄存器组GPR
                                if (dmi_data[31:24] == 8'h0) begin //cmdtype==0，访问寄存器
                                    if (dmi_data[22:20] > 3'h2) begin //aarsize > 2
                                        abstractcs_cmderr <= 3'b011; //abstractcs_cmderr=011标记错误
                                    end else begin //aarsize <= 2
                                        abstractcs_cmderr <= 3'h0;//abstractcs_cmderr清零，无错误
                                        if (dmi_data[18] == 1'b0) begin //postexec=0，不使用程序缓冲区
                                            dm_reg_addr <= dmi_data[15:0] - 16'h1000; //regno，仅支持访问GPR，基地址0x1000
                                            if (dmi_data[16] == 1'b0) begin //write==0，读操作
                                                if (dmi_data[15:0] == DCSR) begin //读取核心调试寄存器dcsr
                                                    data0 <= dcsr;
                                                end 
                                                else begin
                                                    if (dmi_data[15:0] < 16'h1020) begin //读取GPR
                                                        is_read_reg <= 1'b1; //置位标记
                                                    end
                                                end
                                            end 
                                            else begin  //write==1，写操作，硬件不支持
                                                if (dmi_data[15:0] < 16'h1020) begin
                                                    //dm_reg_we <= 1'b1;
                                                    //dm_reg_wdata <= data0;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            DATA0: begin
                                data0 <= dmi_data;
                            end
                            SBCS: begin
                                sbcs_sbreadonaddr <= dmi_data[20];
                                sbcs_sbaccess <= dmi_data[19:17];
                                sbcs_sbautoincrement <= dmi_data[16];
                                sbcs_sbreadondata <= dmi_data[15];
                            end
                            SBADDRESS0: begin
                                sbaddress0 <= dmi_data;
                                if (sbcs_sbreadonaddr == 1'b1) begin
                                    dm_mem_addr <= dmi_data;
                                end
                            end
                            SBDATA0: begin
                                dm_mem_addr <= sbaddress0;
                                dm_mem_wdata <= dmi_data;
                                dm_mem_we <= 1'b1;
                                if (sbcs_sbautoincrement == 1'b1) begin
                                    sbaddress0 <= sbaddress0_next;
                                end
                            end
                        endcase
                    end

                    DTM_OP_NOP: begin  //什么都不做
                        dmi_rsp_data <= {(DMI_DATA_BITS){1'b0}};
                    end
                endcase
            end
            
            STATE_END: begin //结束本次操作
                state <= STATE_IDLE;
                dm_mem_rdata <= dm_mem_rdata_i;
                need_resp <= 1'b0;
                dm_mem_we <= 1'b0;
                dm_reg_we <= 1'b0;
                dm_reset_req <= 1'b0;
            end
        endcase
    end
end




assign dm_reg_we_o = dm_reg_we;
assign dm_reg_addr_o = dm_reg_addr;
assign dm_reg_wdata_o = dm_reg_wdata;

assign dm_mem_sel_o = dm_mem_sel;
assign dm_mem_we_o = dm_mem_we;
assign dm_mem_addr_o = dm_mem_addr;
assign dm_mem_wdata_o = dm_mem_wdata;
assign req_valid_o = (state != STATE_IDLE) & req_sys_bus;

assign dm_halt_req_o = dm_halt_req;
assign dm_reset_req_o = dm_reset_req;

assign dm_resp_data = {dmi_addr, dmi_rsp_data, OP_SUCC};//dm->dtm

//跨时钟域的DMI
full_handshake_tx #(
    .DW(DM_RESP_BITS)
) tx(
    .clk(clk),
    .rst_n(rst_n),
    .ack_i(dtm_ack_i),
    .req_i(need_resp),
    .req_data_i(dm_resp_data),
    .idle_o(),
    .req_o(dm_resp_valid_o),
    .req_data_o(dm_resp_data_o)
);

full_handshake_rx #(
    .DW(DTM_REQ_BITS)
) rx(
    .clk(clk),
    .rst_n(rst_n),
    .req_i(dtm_req_valid_i),
    .req_data_i(dtm_req_data_i),
    .ack_o(dm_ack_o),
    .recv_data_o(rx_data),
    .recv_rdy_o(rx_valid)
);

endmodule

/*
"jtag_dm.v is licensed under Apache-2.0 (http://www.apache.org/licenses/LICENSE-2.0)
   by Blue Liang, liangkangnan@163.com.
*/