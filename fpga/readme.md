# 说明
此目录存放了可以直接运行的FPGA工程  

### anlogic
安路的FPGA，使用TD 5.0.5版本  
IO约束匹配[SparkRoad-V开发板](https://gitee.com/verimake/SparkRoad-V)，可直接烧录并打印HelloWorld  
注意：当前版本的TD不支持指定include路径，因此`config.v`、`define.v`已经复制到了工程目录，修改`rtl/config.v`不能起到改变配置的作用，需要修改`fpga/anlogic/config.v`。  

### gowin(施工中)
高云的FPGA，使用云源软件v1.9.8.09教育版  
IO约束匹配[Sipeed Tang Primer 20K](https://wiki.sipeed.com/hardware/zh/tang/tang-primer-20k/primer-20k.html)，可直接烧录并打印HelloWorld  
