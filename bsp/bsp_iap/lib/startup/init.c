#include "system.h"

//系统初始化，会在main()函数之前执行
void sparrowrv_system_init()
{
    uint32_t tmp;
    //设置中断向量表基地址
    //write_csr(mtvec, &trap_vector_tab);
    //读取系统信息
    tmp=read_csr(mimpid);
    system_cpu_freq = (tmp & 0x00007FFF) * 10000;
    //system_cpu_freqM = system_cpu_freq / 1000000UL;
    //system_iram_size = ((tmp & 0x00FF0000) >> 16)*1024;
    //system_sram_size = (tmp >> 24)*1024;
    //system_vendorid = read_csr(mvendorid);

    //可以写点其他的初始化代码
}
