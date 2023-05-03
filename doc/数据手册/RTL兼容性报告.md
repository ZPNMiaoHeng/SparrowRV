# RTL兼容性报告

## SRAM模式配置
`define SRAM_MODEL "DP_RAM"`  
支持以下综合器：  
1. 高云 Gowin V1.9.8.09 Education
2. AMD Vivado 2019.2
3. 智多晶 HqFPGA 3.0.0

以下综合器存在问题：  
1. 紫光同创Pango Design Suite 2021.4-SP1.2
iram中双端口ram被综合为硬SRAM，但是消耗量为双倍

2. 安路TD 5.6.1
双端口ram被综合为LUT RAM，必须使用参数"DP_ROM"

