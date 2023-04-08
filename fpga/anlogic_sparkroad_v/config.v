/*--------------------------------
 *          参数配置区           
 *--------------------------------*/
//系统主频，根据具体场景填写
`define CPU_CLOCK_HZ 27_000_000

//iram指令存储器大小，单位为KB
`define IRam_KB 32 

//sram数据存储器大小，单位为KB
`define SRam_KB 16

//FPIOA端口数量，范围是[1,32]
`define FPIOA_PORT_NUM 16

//SRAM模式配置，支持"DP_ROM" "DP_RAM" "SYN_DPR" "EG4_32K"
`define SRAM_MODEL "DP_ROM"

//Vendor ID
`define MVENDORID_NUM 32'h114514

//微架构编号
`define MARCHID_NUM 32'd1

//线程编号
`define MHARTID_NUM 32'd0

//除法器模式，支持"HF_DIV" "HP_DIV" "SIM_DIV"
`define DIV_MODE "HF_DIV"

/*--------------------------------
 *          参数配置区           
 *--------------------------------*/


/*--------------------------------
 *          开关配置区           
 *--------------------------------*/
//将程序固化到FPGA内部，SRAM模式必须配置为"DP_ROM"或"DP_RAM"
`define PROG_IN_FPGA 1'b1
//固化到FPGA内部的程序路径，只能导入转换后的文本文件，斜杠方向必须改为/
`define PROG_FPGA_PATH "C:/Users/wu/Desktop/gitee/SparrowRV/tb/inst.txt"

//启用M扩展(乘法/除法)
`define RV32_M_ISA 1'b1

//使用RV32I基础整数指令集，注释掉则使用RV32E
`define RV32I_BASE_ISA 1'b1

//启用JTAG调试
`define JTAG_DBG_MODULE 1'b1

//启用单周期乘法器，可能会降低最大频率
`define SGCY_MUL 1'b1

//启用minstret指令计数器
`define CSR_MINSTRET_EN 1'b1

//开发版本
`define DEVELOP_REV 1'b1


/*--------------------------------
 *          开关配置区           
 *--------------------------------*/