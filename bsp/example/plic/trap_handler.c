#include "system.h"

//函数声明区
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));




/* 功能解释
__attribute__((weak)) 表示本函数弱定义，可以在其他地方写同名函数来覆盖
__attribute__((interrupt("machine"))) 表示本函数用于中断，编译器自动为其保存上下文
interrupt("machine") 表示本函数是机器模式中断
*/

/*
//定时器中断服务程序
__attribute__((weak)) void SysTick_Handler() __attribute__((interrupt("machine")));
void SysTick_Handler()
{
    //printf("interrupt tcmp in original function\n");
}
*/
/*
//软件中断服务程序
__attribute__((weak)) void SW_Handler() __attribute__((interrupt("machine")));
void SW_Handler()
{
    //printf("interrupt soft in original function\n");
}
*/
/*
//硬件错误引发异常
//__attribute__((weak)) void HardFault_Handler() __attribute__((interrupt("machine")));
void HardFault_Handler()
{
    while(1);
}
*/

