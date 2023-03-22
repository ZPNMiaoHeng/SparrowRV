#define RV32_BYTE 4

    .section      .text.entry
    .align 2
    .global trap_entry

trap_entry:
    /*SP压栈*/
    addi sp, sp, -16*4
    /*保存16个寄存器*/
    sw x1 , 0*RV32_BYTE(sp)
    sw x5 , 1*RV32_BYTE(sp)
    sw x6 , 2*RV32_BYTE(sp)
    sw x7 , 3*RV32_BYTE(sp)
    sw x10, 4*RV32_BYTE(sp)
    sw x11, 5*RV32_BYTE(sp)
    sw x12, 6*RV32_BYTE(sp)
    sw x13, 7*RV32_BYTE(sp)
    sw x14, 8*RV32_BYTE(sp)
    sw x15, 9*RV32_BYTE(sp)
//#ifndef __riscv_32e
    sw x16, 10*RV32_BYTE(sp)
    sw x17, 11*RV32_BYTE(sp)
    sw x28, 12*RV32_BYTE(sp)
    sw x29, 13*RV32_BYTE(sp)
    sw x30, 14*RV32_BYTE(sp)
    sw x31, 15*RV32_BYTE(sp)
//#endif
/*根据ABI调用规则，a0 a1用于传递参数至下一个调用的函数*/
    csrr a0, mcause /*中断原因写入a0*/
    csrr a1, mepc   /*返回地址写入a1*/
/*test_if_asynchronous:*/
	/*srli a2, a0, 31*/		                /*mcause的最高位如果是1，则为异步中断*/
	/*beq a2, x0, handle_synchronous*/		/*如果不是异步中断，需要mepc+4。SparrowRV不需要*/

    call trap_handler  /*中断处理函数*/
    j asynchronous_return  /*恢复现场并返回*/

    /*SparrowRV在任何情况下进入trap都会保存当前尚未写回的指令的PC*/
/*handle_synchronous:
    addi a1, a1, 4
    csrw mepc, a1*/

asynchronous_return:
    /*SP出栈*/
    /*恢复16个寄存器*/
    lw x1 , 0*RV32_BYTE(sp)
    lw x5 , 1*RV32_BYTE(sp)
    lw x6 , 2*RV32_BYTE(sp)
    lw x7 , 3*RV32_BYTE(sp)
    lw x10, 4*RV32_BYTE(sp)
    lw x11, 5*RV32_BYTE(sp)
    lw x12, 6*RV32_BYTE(sp)
    lw x13, 7*RV32_BYTE(sp)
    lw x14, 8*RV32_BYTE(sp)
    lw x15, 9*RV32_BYTE(sp)
    lw x16, 10*RV32_BYTE(sp)
    lw x17, 11*RV32_BYTE(sp)
    lw x28, 12*RV32_BYTE(sp)
    lw x29, 13*RV32_BYTE(sp)
    lw x30, 14*RV32_BYTE(sp)
    lw x31, 15*RV32_BYTE(sp)


    addi sp, sp, 16*RV32_BYTE

    mret  /*中断返回*/


.weak trap_handler /*若没有定义中断处理函数*/
trap_handler:
1:
    j 1b /*死循环*/
