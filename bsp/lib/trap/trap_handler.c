#include "system.h"

//函数声明区
void EX_PLIC0_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SW_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void HardFault_Handler() __attribute__((interrupt("machine")));
/* 功能解释 
__attribute__((weak)) 表示本函数弱定义，可以在其他地方写同名函数来覆盖
__attribute__((interrupt("machine"))) 表示本函数用于中断，编译器自动为其保存上下文
interrupt("machine") 表示本函数是机器模式中断
*/


//外部中断 PLIC ID0 服务程序，仅供测试
void EX_PLIC0_Handler()
{
    printf("PLIC ID:0 interrupt\n");
}

//定时器中断服务程序
void SysTick_Handler()
{
    //printf("interrupt tcmp in original function\n");
}

//软件中断服务程序

void SW_Handler()
{
    //printf("interrupt soft in original function\n");
}

//硬件错误引发异常
void HardFault_Handler()
{
    //printf("HardFault,Sys err!\n");
    while(1);
}


