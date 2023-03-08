#ifndef SYSTEM_H_
#define SYSTEM_H_

#include <stdint.h>
#include "utils.h"
#include "trap.h"
#include "printf.h"
#include "uart.h"
#include "spi.h"
#include "fpioa.h"
//#include "nor25_flash.h"

//开启仿真模式printf。不会打印串口，只通过CSR_msprint打印至终端，极大提高速度
#define sim_csr_printf 1

//系统主频
#define CPU_FREQ_HZ   24000000UL //你的工作频率Hz
#define CPU_FREQ_MHZ  (CPU_FREQ_HZ/1000000UL)

#define ENABLE 1
#define DISABLE 0

//自定义CSR
#define msprint    0x346  //仿真打印
#define mends      0x347  //仿真结束
#define minstret   0xB02  //minstret低32位
#define minstreth  0xB82  //minstret高32位
#define mtime      0xB03  //mtime低32位
#define mtimeh     0xB83  //mtime高32位
#define mtimecmp   0xB04  //mtimecmp低32位
#define mtimecmph  0xB84  //mtimecmp高32位
#define mcctr      0xB88  //系统控制
//[0]:保留
//[1]:minstret使能
//[2]:mtime使能
//[3]:soft_rst写1复位
//[4]:保留

//陷阱相关
#define MCAUSE_INTERRUPT 0x80000000 //进入陷阱的原因是中断
#define MCAUSE_INTP_EX   11//外部中断
#define MCAUSE_INTP_TCMP 7//定时器中断
#define MCAUSE_INTP_SOFT 3//软件中断
#define MCAUSE_INTP_XXXX 12//其他中断源
//异常
#define MCAUSE_EXCP_ALL 0xffff



#define SYS_RWMEM_W(addr) (*((volatile uint32_t *)(addr)))   //必须4字节对齐访问(低2位为0)
#define SYS_RWMEM_B(addr) (*((volatile uint8_t  *)(addr)))   //允许访问4G地址空间任意字节，但是部分外设不支持字节寻址写

#endif
