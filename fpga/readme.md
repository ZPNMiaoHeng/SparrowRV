# 说明
此目录存放了可以直接运行的FPGA工程  

### 高云GOWIN
优先支持平台  
综合器支持Verilog推断双端口RAM，使用简单。  
综合过程中，如果出现如下报错：  
```
WARN  (EX3988) : Cannot open file '..\..\tb\inst.txt'("C:\Users\wu\Desktop\gitee\SparrowRV\rtl\core\dpram.v":120)
```
表明综合器读入程序失败，软件程序没有随着RTL设计一起烧进FPGA  

#### gowin_tang_nano_20k (优先支持)
高云GW2A-LV18PG256C8/I7，云源软件v1.9.8.09教育版  
使用[Sipeed Tang nano 20K开发板](https://wiki.sipeed.com/hardware/zh/tang/tang-nano-20k/nano-20k.html)，时序/IO约束与此硬件匹配，可直接烧录并打印HelloWorld  
`fpga/gowin/硬件资料`存放了Sipeed开发板的相关资料  
为了便于移动工程文件夹，如果工程发送文件变动，需要将`gowin.gprj`中的源文件路径改为`../../rtl/**`这种相对路径  

#### gowin_

### 安路Anlogic
#### anlogic_sparkroad_v
安路EG4S20BG256，TD 5.0.5版本  
使用[SparkRoad-V开发板](https://gitee.com/verimake/SparkRoad-V)，时序/IO约束与此硬件匹配，可直接烧录并打印HelloWorld  
- 目前TD不支持Verilog推断双端口BRAM，因此只能将iram配置为ROM模式，在综合阶段写入程序。  
- 当前版本的TD不支持指定include路径，因此`config.v`、`define.v`已经复制到了工程目录，修改`rtl/config.v`不能起到改变配置的作用，需要修改fpga工程目录的`fpga/anlogic/config.v`。  
- 希望TD日后可以改进。  


