#include "system.h"

uint8_t tmp;
//测试
int main()
{
    init_uart0_printf(115200,0);//设置波特率
    printf("%s", "Hello world SparrowRV\n");
    printf("%s", "https://gitee.com/xiaowuzxc/SparrowRV\n");
    printf("sys freq = %lu Hz\n",system_cpu_freq);
    printf("cpu_iram_size = %lu Byte\n",system_iram_size);
    printf("cpu_sram_size = %lu Byte\n",system_sram_size);
    printf("Vendor ID = %lx \n\n",system_vendorid);
}
