#include <stdint.h>

#include "core.h"


extern void trap_vector_tab();


void _init()
{
    // 设置中断向量表基地址
    write_csr(mtvec, &trap_vector_tab);
    // 使能CPU全局中断
    // MIE = 1, MPIE = 1, MPP = 11
    //write_csr(mstatus, 0x1888);
}
