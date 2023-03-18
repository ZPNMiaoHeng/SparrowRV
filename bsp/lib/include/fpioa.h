#ifndef _FPIOA_H_
#define _FPIOA_H_

#include "system.h"
#define SYSIO_BASE                  (0x40000000)
#define FPIOA_BASE                  (SYSIO_BASE + (0xF00))
#define FPIOA_OT_BASE               (FPIOA_BASE)
#define FPIOA_NIO_BASE              (FPIOA_OT_BASE + (0x20))
#define FPIOA_IN_BASE               (FPIOA_BASE + (0x80))

#define FPIOA_NIO_DIN              (FPIOA_NIO_BASE + (0x00))
#define FPIOA_NIO_OPT              (FPIOA_NIO_BASE + (0x04))
#define FPIOA_NIO_MD0              (FPIOA_NIO_BASE + (0x08))
#define FPIOA_NIO_MD1              (FPIOA_NIO_BASE + (0x0c))

//定义NIO模式
#define NIO_MODE_HIGHZ      0x00  //高阻输入
#define NIO_MODE_OE_PP      0x02  //推挽输出
#define NIO_MODE_OE_OD      0x03  //开漏输出


void fpioa_perips_out_set(uint8_t fpioa_perips_o, uint8_t FPIOAx);
void fpioa_perips_in_set(uint8_t fpioa_perips_i, uint8_t FPIOAx);
uint8_t fpioa_out_read(uint8_t FPIOAx);
uint8_t fpioa_in_read(uint8_t fpioa_perips_i);

uint32_t fpioa_nio_din_read();
void fpioa_nio_dout_write(uint32_t fpioa_nio_dout);
uint32_t fpioa_nio_dout_read();
void fpioa_nio_mode_write(uint32_t NIO_x, uint8_t nio_mode);
uint64_t fpioa_nio_mode_read();


//定义fpioa_perips_o参数
#define  NIO           0 
#define  SPI0_SCK      1 
#define  SPI0_MOSI     2 
#define  SPI0_CS       3 
#define  SPI1_SCK      4 
#define  SPI1_MOSI     5 
#define  SPI1_CS       6 
#define  UART0_TX      7 
#define  UART1_TX      8 


//定义fpioa_perips_i参数
#define  SPI0_MISO     0
#define  SPI1_MISO     1
#define  UART0_RX      2
#define  UART1_RX      3





//定义GPIO端口
#define NIO_0    0b1
#define NIO_1    0b10
#define NIO_2    0b100
#define NIO_3    0b1000
#define NIO_4    0b10000
#define NIO_5    0b100000
#define NIO_6    0b1000000
#define NIO_7    0b10000000
#define NIO_8    0b100000000
#define NIO_9    0b1000000000
#define NIO_10   0b10000000000
#define NIO_11   0b100000000000
#define NIO_12   0b1000000000000
#define NIO_13   0b10000000000000
#define NIO_14   0b100000000000000
#define NIO_15   0b1000000000000000
#define NIO_16   0b10000000000000000
#define NIO_17   0b100000000000000000
#define NIO_18   0b1000000000000000000
#define NIO_19   0b10000000000000000000
#define NIO_20   0b100000000000000000000
#define NIO_21   0b1000000000000000000000
#define NIO_22   0b10000000000000000000000
#define NIO_23   0b100000000000000000000000
#define NIO_24   0b1000000000000000000000000
#define NIO_25   0b10000000000000000000000000
#define NIO_26   0b100000000000000000000000000
#define NIO_27   0b1000000000000000000000000000
#define NIO_28   0b10000000000000000000000000000
#define NIO_29   0b100000000000000000000000000000
#define NIO_30   0b1000000000000000000000000000000
#define NIO_31   0b10000000000000000000000000000000


#endif
