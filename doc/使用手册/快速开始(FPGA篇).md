# 快速开始(FPGA篇)

## 简介
小麻雀处理器包含了RTL设计和BSP板级支持包，部署在FPGA上需要完成软硬件配置工作  

## 1.环境准备
参考[搭建开发环境](/doc/使用手册/搭建开发环境.md)，其中iverilog不是必需的  

## 2.编译软件
打开`bsp/SparrowRV.wvproj`，启动MRS并进入工作空间  
打开`bsp/lib/system.h`，把15行`#define CPU_FREQ_HZ   24000000UL`修改为你在FPGA上的工作频率  
打开`bsp/app/main.c`，把`init_uart0_printf(25000000);`中的`25000000`改成你需要的波特率  
点击左上角编译  

## 3.转化二进制文件
编译后在`bsp/obj/`文件夹生成`SparrowRV.bin`文件，需要将它转为文本文件才能被HDL仿真器或FPGA综合器读入  
打开`tb/run_zh.bat`，输入数字`2`并回车，出现文件选择界面  
找到`bsp/obj/SparrowRV.bin`文件并打开，会生成`tb/inst.txt`  

## 调整RTL配置
小麻雀处理器的RTL设计`rtl/`包含了`源文件.v`和`头文件.v`，头文件只有此目录下的`config.v`和`define.v`，`config.v`是需要使用者修改的  
为了保证最佳的兼容性需要做以下设置： 
|宏定义|配置|
|-|-|
|CPU_CLOCK_HZ|处理器在FPGA上的主频|
|SRAM_MODEL|"DP_ROM"|
|PROG_IN_FPGA|打开宏定义|
|PROG_FPGA_PATH|设置为inst.txt的路径，斜杠方向必须为/|

## 逻辑综合
这一步涉及具体的FPGA平台，我默认你会FPGA开发流程，在此只能提供一些注意事项  
`rtl/`目录下所有文件都必须添加  
`config.v`和`define.v`是头文件，需要加入`include path`  
建议做时钟约束，模板如下  
```
create_clock -period 40.000 -name clk [get_ports clk]
create_clock -period 100.000 -name jtag_clk [get_ports JTAG_TCK]
set_clock_groups -asynchronous -group [get_clocks clk] -group [get_clocks {jtag_clk}]
```
IO约束，根据自己的板子来吧  

### 示例工程
我在`fpga/anlogic`提供了安路SparkRoad开发板的示例工程，对应安路EG4S20 FPGA器件

## HelloWorld
连接并打开你的串口  
上电、烧录  
看Helloworld！  
