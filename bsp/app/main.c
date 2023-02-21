#include "system.h"
uint8_t cnt;
uint32_t sm3_tmp;
//测试
int main()
{
    init_uart0_printf(115200);//设置波特率
    printf("%s", "Hello world SparrowRV\n");
    sm3_tmp=read_csr(mimpid);
    printf("mimpid l=%lu\n",sm3_tmp&0x0000FFFF);
    printf("mimpid h=%lu\n",sm3_tmp>>16);
    printf("%s", "Hello world SparrowRV\n");
    while(1)
    {
        printf("%s", "Hello world SparrowRV\n");
    }
    
}
