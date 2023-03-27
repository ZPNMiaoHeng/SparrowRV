#include "uart.h"


/*********************************************************************
 * @fn      uart_enable_ctr
 *
 * @brief   串口使能控制
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 * @param   uart_en - 串口使能选择位
 *            ENABLE - 使能
 *            DISABLE - 关闭
 *
 * @return  无
 */
void uart_enable_ctr(uint32_t UARTx, uint32_t uart_en)
{
    if(uart_en == ENABLE)
    {
        SYS_RWMEM_W(UART_CTRL(UARTx)) = 0x3;
    }
    else
    {
        SYS_RWMEM_W(UART_CTRL(UARTx)) = 0x0;
    }
}


/*********************************************************************
 * @fn      uart_band_ctr
 *
 * @brief   串口波特率控制
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 * @param   uart_band - 写入所需的波特率值
 *
 * @return  无
 */
void uart_band_ctr(uint32_t UARTx, uint32_t uart_band)
{
    SYS_RWMEM_W(UART_BAUD(UARTx)) = CPU_FREQ_HZ / uart_band ; //计算出分频器的值
}


/*********************************************************************
 * @fn      uart_send_date
 *
 * @brief   串口发送数据
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 * @param   uart_send - 需要发送的数据
 *
 * @return  无
 */
void uart_send_date(uint32_t UARTx, uint8_t uart_send)
{
    while (SYS_RWMEM_W(UART_STATUS(UARTx)) & 0x1); //等待上一个操作结束
    SYS_RWMEM_W(UART_TXDATA(UARTx)) = uart_send;
}


/*********************************************************************
 * @fn      uart_recv_date
 *
 * @brief   串口接收数据
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *
 * @return  返回接收到的数据
 */
uint8_t uart_recv_date(uint32_t UARTx)
{
    SYS_RWMEM_W(UART_STATUS(UARTx)) &= ~0x2;//清除接收标志
    return (SYS_RWMEM_W(UART_RXDATA(UARTx)) & 0xff);//返回串口接收到的数据
}


/*********************************************************************
 * @fn      uart_recv_flg
 *
 * @brief   串口接收状态查询
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *
 * @return  如果接收缓冲区有数据，返回1；没有为0
 */
uint8_t uart_recv_flg(uint32_t UARTx)
{
    if (SYS_RWMEM_W(UART_STATUS(UARTx)) & 0x2)//有数据
    {
        return 1;
    }
    else//没有数据
    {
        return 0;
    }
}


