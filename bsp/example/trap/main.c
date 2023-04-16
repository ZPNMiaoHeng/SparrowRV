#include "system.h"
uint8_t cnt;
uint32_t sm3_tmp;
//测试
int main()
{
    init_uart0_printf(115200,0);//设置printf波特率
    printf("%s", "Hello world SparrowRV\n");

    trap_global_ctrl(ENABLE);//打开全局中断
    trap_en_ctrl(TRAP_EXTI, ENABLE);//打开外部中断
    delay_mtime_us(10);
    printf("exit_trap=%lu\n",trap_mip_state(TRAP_EXTI));//已经响应了，返回0
}

