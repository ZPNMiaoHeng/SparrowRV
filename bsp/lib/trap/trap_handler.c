#include "system.h"

//外部中断服务程序
__attribute__((weak)) void handler_interrupt_ex()
{
    printf("interrupt ex in original function\n");
}

//定时器中断服务程序
__attribute__((weak)) void handler_interrupt_tcmp()
{
    printf("interrupt tcmp in original function\n");
}

//软件中断服务程序
__attribute__((weak)) void handler_interrupt_soft()
{
    printf("interrupt soft in original function\n");
}

//异常服务程序
__attribute__((weak)) void handler_exception()
{
    printf("THis is exception, SYS has error!\n");
}

//中断之后，首先执行这个函数
void trap_handler(uint32_t mcause, uint32_t mepc)
{
    uint32_t mcause_desc = mcause & 0x000FFFFF;//进入陷阱的原因
    if(mcause & MCAUSE_INTERRUPT)//中断interrupt
    {
        switch (mcause_desc) {
            case MCAUSE_INTP_EX://外部中断
                handler_interrupt_ex();
                break;
            case MCAUSE_INTP_TCMP://定时器中断
                handler_interrupt_tcmp();
                break;
            case MCAUSE_INTP_SOFT://软件中断
                handler_interrupt_soft();
                break;
            default://未知中断
                printf("Unknow interrupt mcause\n");
                break;
        }
    }
    else//异常exception
    {
        printf("THis is exception, SYS has error!\n");
    }
}
