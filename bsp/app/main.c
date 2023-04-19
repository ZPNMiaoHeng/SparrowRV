#include "system.h"
uint8_t cnt;
uint32_t tmp;
//测试
int main()
{
    init_uart0_printf(115200,0);//设置波特率
    printf("%s", "Hello world SparrowRV\n");
    printf("%s", "--------------\n");
    fpioa_perips_out_set(TIMER0_CMPO_N, 10);
    fpioa_perips_out_set(TIMER0_CMPO_P, 11);
    fpioa_perips_in_set(TIMER0_CAPI, 1);
    timer_of_irq_ctrl(ENABLE);
    timer_of_irq_ctrl(DISABLE);
    spi_irq_ctrl(SPI0, ENABLE);
    spi_irq_ctrl(SPI0, DISABLE);
    uart_irq_ctrl(UART0, UART_IRQ_RX, ENABLE);
    uart_irq_ctrl(UART0, UART_IRQ_TX, ENABLE);
    uart_irq_ctrl(UART0, UART_IRQ_RX, DISABLE);
    uart_irq_ctrl(UART0, UART_IRQ_TX, DISABLE);
    uart_irq_ctrl(UART1, UART_IRQ_RX, ENABLE);
    uart_irq_ctrl(UART1, UART_IRQ_TX, ENABLE);
    uart_irq_ctrl(UART1, UART_IRQ_RX, DISABLE);
    uart_irq_ctrl(UART1, UART_IRQ_TX, DISABLE);
}
