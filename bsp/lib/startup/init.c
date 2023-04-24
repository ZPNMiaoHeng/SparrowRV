#include <stdint.h>

#include "core.h"


extern void trap_vector_tab();//声明外部的中断向量表

//系统初始化，会在main()函数之前执行
void sparrowrv_system_init()
{
    //设置中断向量表基地址
    write_csr(mtvec, &trap_vector_tab);
    //可以写点其他的初始化代码
}
