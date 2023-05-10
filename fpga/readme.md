# 说明
此目录存放了可以直接运行的FPGA工程。
首先按照[快速开始](/doc/使用手册/快速开始.md)的步骤完成程序编译，生成`inst.txt`，再使用FPGA厂商软件完成综合步骤，同时读入`inst.txt`作为程序。  
如果使用自建的FPGA工程，需要手动将`/rtl/config.h`的`PROG_FPGA_PATH`宏定义改为`inst.txt`的文件路径。  

### 高云GOWIN
优先支持高云FPGA平台  
综合器支持Verilog推断双端口RAM，使用简单。  
若自建的FPGA工程在综合过程中如果出现如下报错：  
```
WARN  (EX3988) : Cannot open file '..\..\tb\inst.txt'("XXX\SparrowRV\rtl\core\dpram.v":120)
```
表明`config.h`的`PROG_FPGA_PATH`没有指向`inst.txt`，综合器读入程序失败，软件程序没有随着RTL设计一起烧进FPGA。  
工程文件`gowin_xxx.gprj`的源文件默认采用绝对地址，可手动将地址改为相对地址`../../rtl/**`，移动文件夹也能正常使用。   

#### gowin_tang_nano_20k (优先支持)
高云GW2A-LV18PG256C8/I7，云源软件v1.9.8.09教育版  
使用[Sipeed Tang nano 20K开发板](https://wiki.sipeed.com/hardware/zh/tang/tang-nano-20k/nano-20k.html)，时序/IO约束与此硬件匹配，可直接烧录并打印HelloWorld  
IO分配如下：  
|IO编号|引脚名称|功能|
|---|---|---|
|4|clk|时钟输入，连接27MHz晶振|
|16|hard_rst_n|低电平复位，连接LED1|
|15|core_active|活动指示，连接LED0|
|69|fpioa\[0\]|printf>uart0_tx输出，连接USB串口|
|27|JTAG_TDI|JTAG调试接口|
|28|JTAG_TDO|JTAG调试接口|
|29|JTAG_TCK|JTAG调试接口|
|30|JTAG_TMS|JTAG调试接口|
|83|sd_clk|SD卡的SDIO_CLK|
|82|sd_cmd|SD卡的SDIO_CMD|
|84|sd_dat\[0\]|SD卡的SDIO_D0|
|85|sd_dat\[1\]|SD卡的SDIO_D1|
|80|sd_dat\[2\]|SD卡的SDIO_D2|
|81|sd_dat\[3\]|SD卡的SDIO_D3|


#### gowin_tang_primer_20k
高云GW2A-LV18PG256C8/I7，云源软件v1.9.8.09教育版  
使用[Sipeed Tang Primer 20K开发板](https://wiki.sipeed.com/hardware/zh/tang/tang-primer-20k/primer-20k.html)，时序/IO约束与此硬件匹配，可直接烧录并打印HelloWorld  
IO分配如下：  
|IO编号|引脚名称|功能|
|---|---|---|
|H11|clk|时钟输入，连接27MHz晶振|
|T10|hard_rst_n|低电平复位，连接S0|
|N16|core_active|活动指示，连接LED2|
|M11|fpioa\[0\]|printf>uart0_tx输出，连接USB串口|
||JTAG_TDI|JTAG调试接口|
||JTAG_TDO|JTAG调试接口|
||JTAG_TCK|JTAG调试接口|
||JTAG_TMS|JTAG调试接口|
|N10|sd_clk|SD卡的SDIO_CLK|
|R14|sd_cmd|SD卡的SDIO_CMD|
|M8|sd_dat\[0\]|SD卡的SDIO_D0|
|M7|sd_dat\[1\]|SD卡的SDIO_D1|
|M10|sd_dat\[2\]|SD卡的SDIO_D2|
|N11|sd_dat\[3\]|SD卡的SDIO_D3|

### 安路Anlogic
由于综合器不支持双端口字节写选通RAM，不太建议使用  
#### anlogic_sparkroad_v
安路EG4S20BG256，TD 5.0.5版本  
使用[SparkRoad-V开发板](https://gitee.com/verimake/SparkRoad-V)，时序/IO约束与此硬件匹配，可直接烧录并打印HelloWorld  
- 目前TD不支持Verilog推断双端口BRAM，因此只能将iram配置为ROM模式，在综合阶段写入程序。  
- 目前TD不支持指定include路径，因此`config.v`、`define.v`已经复制到了工程目录，修改`rtl/config.v`不能起到改变配置的作用，需要修改fpga工程目录的`fpga/anlogic/config.v`。  
- 希望TD日后可以改进。  


