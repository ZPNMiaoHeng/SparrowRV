# 小麻雀处理器
[![rvlogo](/doc/图库/Readme/rvlogo.bmp)RISC-V官网收录](https://riscv.org/exchange/?_sf_s=sparrowrv)  
[![teelogo](/doc/图库/Readme/giteetj.bmp)Gitee推荐项目](https://gitee.com/explore/risc-v)  
[![book](/doc/图库/Readme/book.png)处理器文档导航页](/doc/文档导航.md)  

## 简介
小麻雀处理器(SparrowRV)是一款RISC-V架构的32位单周期两级流水线处理器。它的控制逻辑简单，没有复杂的流水线控制结构，代码注释完备，配有易上手的仿真环境和软件开发环境，适合用于学习。  
此项目处于开发阶段，master分支更新频繁，稳定版请参阅[release发行版](https://gitee.com/xiaowuzxc/SparrowRV/releases)  
**设计指标：**  
- 顺序两级流水线结构(IF -> ID+EX+MEM+WB)  
- 兼容RV32I基础指令集和M、Zicsr、Zifencei扩展  
- 支持固定入口中断，仅支持机器模式  
- 哈佛结构，指令存储器映射至存储器空间  
- 支持C语言，有配套BSP  
- 支持ICB总线  
- 支持JTAG调试(有BUG)  

**2级流水线**  
![流水线](/doc/图库/Readme/流水线.svg)  

**系统功能框图**  
![soc架构](/doc/图库/Readme/soc架构.svg)  

**内核原理图**  
![内核原理图](/doc/图库/内核手册/内核原理图.svg)  

软件开发请参阅[板级支持包BSP](#板级支持包bsp)  
仿真环境搭建请参阅[仿真流程](#仿真)  

## 设计进度
```
SoC RTL
 ├─内核
 │   ├─译码执行 (完成)
 │   ├─iram (完成)
 │   ├─CSR  (Debug 99%)
 │   ├─寄存器组 (完成)
 │   ├─总线接口 (Debug 98%)
 │   ├─中断控制 (Debug 95%)
 │   └─多周期指令控制 (OK)
 ├─外设 (30%)
 └─调试 (75%)

软件部分
 ├─指令仿真 (完成)
 └─BSP (随设计扩展驱动程序)
```
**当前任务**  
- JTAG修复  
- 向量化的中断系统  

**未来任务**  
- 完善的文档  


## 开发工具
- 处理器RTL设计采用Verilog-2001可综合子集。此版本代码密度更高，可读性更强，并且受到综合器的广泛支持。  
- 处理器RTL验证采用System Verilog-2005。此版本充分满足仿真需求，并且受到仿真器的广泛支持。   
- 数字逻辑仿真采用iverilog/Modelsim。可根据使用平台与具体需求选择合适工具。  
- 脚本采用 Batchfile批处理(Win)/Makefile(Linux) + Python3。发挥各种脚本语言的优势，最大程度地简化操作。  
- 板级支持包采用MRS(MounRiver Studio)图形化集成开发环境，做到开箱即用。  
- 所有文本采用UTF-8编码，具备良好的多语言和跨平台支持。  

## 仿真
本工程使用`批处理/Makefile + Python3 + Modelsim/iverilog`可根据个人喜好与平台使用合适的工具完成仿真全流程。如果已配置相关工具，可跳过环境搭建步骤。    
若需要编写c语言程序并仿真，请参阅[板级支持包BSP](#板级支持包bsp)  
**仿真环境框架**  
![soc架构](/doc/图库/Readme/仿真环境.svg)  

### Linux环境搭建与仿真
必须使用带有图形化界面的Linux的系统，否则无法正常仿真。    
Linux下仅支持iverilog  
Debian系(Ubuntu、Debian、Deepin)执行以下命令：  
```
sudo apt install make git python3 python3-tk gtkwave gcc g++ bison flex gperf autoconf
git clone -b v12_0 --depth=1 https://gitee.com/xiaowuzxc/iverilog/
cd iverilog
sh autoconf.sh
./configure
make
sudo make install
cd ..
rm -rf iverilog/
```
其他Linux发行版暂不提供支持，请自行探索。  

- `/tb/makefile`是Linux环境下的实现各项仿真功能的启动器  

进入`/tb/`目录，终端输入`make`即可启动人机交互界面。根据提示，输入`make`+`空格`+`单个数字或符号`，按下回车即可执行对应项目。   

Makefile支持以下命令：  
- [0]导入inst.txt，RTL仿真并显示波形  
- [1]收集指令测试集程序，测试所有指令  
- [2]转换bin文件为inst.txt，可被testbench读取  
- [3]转换bin文件并进行RTL仿真、显示波形，主要用于仿真c语言程序  
- [4]显示上一次的仿真波形  
- [c]清理缓存文件  

### Windows环境搭建
- 进入[Python官网](https://www.python.org/)，下载并安装Python 3.x版本(建议使用稳定版)  
- (可跳过)如果想在Win系统使用make，请参阅[Makefile开发](#Makefile开发)第2步。  
#### iverilog仿真
进入[iverilog Win发行版](http://bleyer.org/icarus/)，下载并安装iverilog-v12-20220611-x64_setup[18.2MB]  
Windows下iverilog安装流程及仿真可参考[视频教程](https://www.bilibili.com/video/bv1dS4y1H7zn)  
**可选择以下任意一种方式进行仿真**  
- `/tb/run_zh.bat`是Windows环境下的启动器，进入`/tb/`目录，仅需双击`run_zh.bat`即可启动人机交互界面。根据提示，输入单个数字或符号，按下回车即可执行对应项目。  
- `/tb/makefile`是Windows/Linux环境下的启动器，进入`/tb/`目录，终端输入`make`即可启动人机交互界面。根据提示，输入`make`+`空格`+`单个数字或符号`，按下回车即可执行对应项目。   

处理器运行C语言程序，见[板级支持包BSP](#板级支持包bsp)。需要将生成的`obj.bin`转换为`inst.txt`文件，才能导入程序并执行仿真。命令2仅转换，命令3可以转换并仿真。  

`/tb/tools/isa_test.py`是仿真脚本的核心，负责控制仿真流程，转换文件类型，数据收集。使用者通过启动器与此脚本交互，一般情况下不建议修改。  
iverilog是仿真工具，gtkwave用于查看波形。  


#### Modelsim仿真
仅限Windows系统  
本工程提供了Modelsim仿真脚本，启动方式与iverilog类似，软件安装问题请各显神通  
- `/tb/run_zh.bat`是Windows环境下的启动器，进入`/tb/`目录，仅需双击`run_zh.bat`即可启动人机交互界面。根据提示，输入单个数字或符号，按下回车即可执行对应项目。   
- 处理器运行C语言程序，见[板级支持包BSP](#板级支持包bsp)。需要将生成的`obj.bin`转换为`inst.txt`文件(命令2转换，命令3可以直接转换并仿真)，才能导入程序并执行仿真。  
- `/tb/tools/vsim_xxx.tcl`主导Modelsim的启动、配置、编译、仿真流程，由批处理脚本启动，Modelsim启动后读入。  

  

### 问题说明
- inst.txt是被testbench读入指令存储器的文件，必须存在此文件处理器才可运行  
- 程序编译生成的bin文件不能直接被读取，需要先转换为inst.txt  
- iverilog版本建议大于v11，低于此版本可能会无法运行  
- Makefile环境下可能会出现gtkwave开着的情况下不显示打印信息  
- Windows下`make`建议使用Powershell，经测试Bash存在未知bug(实验性修复)   
- (已修复)~~run_zh.bat是中文的启动器，但是由于`git CRLF`相关问题无法使用~~  
- 若出现`WARNING: tb_core.sv:23: $readmemh(inst.txt):...`或`ERROR: tb_core.sv:24: $readmemh:`警告或错误信息，请忽略，它不会有任何影响  
- 本项目基于Modelsim SE 2019.2进行环境搭建，此版本保证脚本的有效性；10.6d版本存在问题  



## 板级支持包BSP
位于`/bsp/`文件夹下   
本工程使用MRS(MounRiver Studio)作为图形化集成开发环境。MRS基于Eclipse开发，支持中文界面和帮助信息，配置了完善的GCC工具链，可以做到开箱即用。  
官网链接http://www.mounriver.com/  
使用流程：  
1. 下载并安装MRS  
2. 切换中文界面。打开MRS主界面，`Help`->`Language`->`Simplified Chinese`  
3. 双击打开`/bsp/SparrowRV.wvproj`
4. 点击`构建项目`，编译并生成bin文件

## 致谢
本项目借鉴了[tinyriscv](https://gitee.com/liangkangnan/tinyriscv)的RTL设计和Python脚本。tinyriscv使用[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)协议。    
本项目借鉴了[SM3_core](https://gitee.com/ljgibbs/sm3_core)的设计内容。SM3_core使用MIT协议。    
本项目使用了[printf](https://github.com/mpaland/printf)的轻量化printf实现。printf使用MIT协议。    
本项目使用了[蜂鸟E203](https://gitee.com/riscv-mcu/e203_hbirdv2)的ICB总线。蜂鸟E203使用[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)协议。  
感谢先驱者为我们提供的灵感  
感谢众多开源软件提供的好用的工具  
感谢MRS开发工具提供的便利   
感谢导师对我学习方向的支持和理解  
大家的支持是我前进的动力！  