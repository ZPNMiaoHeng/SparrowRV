# BSP板级支持包

### bsp_app
面向完整的应用程序  
如果使用SD卡加载程序，需要将`/bsp/bsp_app/link.lds`的`_iap_prog_size`改为1024

### bsp_iap
面向在应用编程(In Application Programming, IAP)程序的BSP，功能是从SD卡加载程序，搬移至iram的相应空间。驱动程序经过大幅度裁剪，以保证占用空间尽可能小。  
`/bsp/SparrowRV_IAP.bin`是编译好的IAP程序，可通过`tb/工具箱.bat`转换为`inst.txt`后随着RTL一起综合并写进FPGA  