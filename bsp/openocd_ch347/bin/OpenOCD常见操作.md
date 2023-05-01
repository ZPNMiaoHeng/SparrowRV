# OpenOCD常见操作

### 启动OpenOCD
双击`启动openocd.bat`  

### 进入命令界面
打开CMD，执行`telnet localhost 4444`  

### 常见命令
`halt`停住内核  
`reset`复位  
`mdw 地址 [长度]`从指定地址读取32bit数据，可指定读取长度  
`load_image 文件名 起始地址 文件类型(bin,ihex,elf,s19) 最小地址 最大长度`加载镜像  
`verify_image 文件名 起始地址`校验镜像  
