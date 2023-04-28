#include "system.h"

uint8_t tmp;
//测试
int main()
{
    init_uart0_printf(115200,0);//设置波特率
    printf("%s", "Hello world SparrowRV\n");
    printf("%s", "--------------\n");
    tmp = sdrd_init_state_read();
    printf("SDRD state:0x%x \n", tmp);
    tmp = sdrd_busy_chk();
    printf("SDRD busy:0x%x \n", tmp);
    sdrd_sector_set(20);
    delay_mtime_us(1);
    tmp = sdrd_buffer_read(0);
    tmp = sdrd_buffer_read(1);
    tmp = sdrd_buffer_read(2);
    tmp = sdrd_buffer_read(0x30);

}
