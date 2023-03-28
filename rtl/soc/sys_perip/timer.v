`include "defines.v"
module timer(

    input wire clk,
    input wire rst_n,

    input wire[7:0] waddr_i,
    input wire[`MemBus] data_i,
    input wire[3:0] sel_i,
    input wire we_i,
    input wire[7:0] raddr_i,
    input wire rd_i,
    output wire[`MemBus] data_o,

	output wire timer_cmpo_p,//比较输出+
	output wire timer_cmpo_n,//比较输出-
    input  wire timer_capi,//输入捕获

    output reg irq_timer_cmp0,   //定时器触发比较值0中断
    output reg irq_timer_cmp1,   //定时器触发比较值1中断
    output reg irq_timer_cap0,   //定时器捕获0中断
    output reg irq_timer_cap1,   //定时器捕获1中断
    output reg irq_timer_wdg,    //定时器看门狗中断
    output reg irq_timer_of      //定时器溢出中断

);

// 寄存器(偏移)地址
localparam TIMER_CTRL = 8'h0;
localparam TIMER_CMPR = 8'h4;
localparam TIMER_CAPR = 8'h8;
localparam TIMER_TWDG = 8'hc;

/* 
 * TIMER_CTRL定时器控制寄存器，0x00
 * [0]：RW，计数器使能，1使能，0暂停
 * [1]：RW，比较输出初始极性
 * [3:2]：RW，捕获0触发配置位
 * [5:4]：RW，捕获1触发配置位
 * [15:6]：RO，读恒为0
 * [31:16]: RW，预分频器
 * 捕获触发模式配置位：
 * 00：不触发      01：上升沿触发
 * 10：下降沿触发  11：双沿触发
*/
reg timer_ctrl;//[0]计数器使能
reg timer_cmpol;//[1]比较输出初始极性
reg [1:0]timer_trig0;//[3:2]捕获0触发配置位
reg [1:0]timer_trig1;//[5:4]捕获1触发配置位
reg [15:0]timer_diver;//[31:16]预分频器

/* 
 * TIMER_CMPR比较寄存器，0x04
 * [15: 0]：RW，比较寄存器0
 * [31:16]：RW，比较寄存器1
*/
reg [15:0]timer_cmpr0;
reg [15:0]timer_cmpr1;

/* 
 * TIMER_CAPR比较寄存器，0x08
 * [15: 0]：RO，捕获寄存器0
 * [31:16]：RO，捕获寄存器1
*/
reg [15:0]timer_capr0;
reg [15:0]timer_capr1;

/* 
 * TIMER_TWDG计数器与喂狗寄存器，0x0c
 * [15: 0]：RW，读写产生不同效果
 * 读：读取当前计数器的值
 * 写：写16'h114_514_19喂狗，写其他数字喂狗无效
*/
reg [15:0]timer_cnt;//Timer的计数器



endmodule
