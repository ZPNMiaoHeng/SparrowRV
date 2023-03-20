#include "fpioa.h"

/*********************************************************************
 * @fn      fpioa_perips_out_set
 *
 * @brief   配置FPIOA输出与外设的映射关系
 *
 * @param   fpioa_perips_o - 选择映射哪个外设输出端口，数据见fpioa.h/fpioa_perips_o参数
 * @param   FPIOAx - x是待配置的FPIOA端口编号，范围是[31:0]
 *
 * @return  无
 */
void fpioa_perips_out_set(uint8_t fpioa_perips_o, uint8_t FPIOAx)
{
    SYS_RWMEM_B(FPIOA_OT_BASE + FPIOAx) = fpioa_perips_o;
}

/*********************************************************************
 * @fn      fpioa_perips_in_set
 *
 * @brief   配置外设与FPIOA输入的映射关系
 *
 * @param   fpioa_perips_i - 待配置的外设输入端口，数据见fpioa.h/fpioa_perips_i参数
 * @param   FPIOAx - x是连接当前外设输入端口的FPIOA端口编号，范围是[31:0]
 *
 * @return  无
 */
void fpioa_perips_in_set(uint8_t fpioa_perips_i, uint8_t FPIOAx)
{
    SYS_RWMEM_B(FPIOA_IN_BASE + fpioa_perips_i) = FPIOAx;
}

/*********************************************************************
 * @fn      fpioa_out_read
 *
 * @brief   读取FPIOA的端口与外设输出的映射关系
 *
 * @param   FPIOAx - x是待读取的FPIOA端口编号，范围是[31:0]
 *
 * @return  连接此FPIOA端口的外设输出编号
 */
uint8_t fpioa_out_read(uint8_t FPIOAx)
{
    return SYS_RWMEM_B(FPIOA_OT_BASE + FPIOAx);
}

/*********************************************************************
 * @fn      fpioa_in_read
 *
 * @brief   读取外设输入与FPIOA的端口的映射关系
 *
 * @param   fpioa_perips_i - 这是待读取的外设输入端口编号
 *
 * @return  连接此外设输入端口的FPIOA编号
 */
uint8_t fpioa_in_read(uint8_t fpioa_perips_i)
{
    return SYS_RWMEM_B(FPIOA_IN_BASE + fpioa_perips_i);
}

/*********************************************************************
 * @fn      fpioa_nio_din_read
 *
 * @brief   读取FPIOA端口的电平状态
 *
 * @return  FPIOA_NIO_DIN寄存器的值
 */
uint32_t fpioa_nio_din_read()
{
    return SYS_RWMEM_W(FPIOA_NIO_DIN);
}

/*********************************************************************
 * @fn      fpioa_nio_dout_write
 *
 * @brief   写入FPIOA_NIO_OPT输出寄存器
 *
 * @param   fpioa_nio_dout - 写入FPIOA_NIO_OPT的数据
 *
 * @return  无
 */
void fpioa_nio_dout_write(uint32_t fpioa_nio_dout)
{
    SYS_RWMEM_W(FPIOA_NIO_OPT) = fpioa_nio_dout;
}

/*********************************************************************
 * @fn      fpioa_nio_dout_read
 *
 * @brief   读取FPIOA_NIO_OPT输出寄存器的数据
 *
 * @return  FPIOA_NIO_OPT的值
 */
uint32_t fpioa_nio_dout_read()
{
    return SYS_RWMEM_W(FPIOA_NIO_OPT);
}

/*********************************************************************
 * @fn      fpioa_nio_mode_write
 *
 * @brief   设置FPIOA NIO的工作模式
 *
 * @param   NIO_x - x为[0,31]，选择需要配置的NIO口，多个NIO可以表示为 NIO_0 | NIO_1 [| NIO_x]...
 * @param   nio_mode - 配置NIO的工作模式
 *            NIO_MODE_HIGHZ - 高阻
 *            NIO_MODE_OE_PP - 推挽输出
 *            NIO_MODE_OE_OD - 开漏输出
 *
 * @return  无
 */
void fpioa_nio_mode_write(uint32_t NIO_x, uint8_t nio_mode)
{
    uint32_t tmp_md0,tmp_md1;
    tmp_md0 = SYS_RWMEM_W(FPIOA_NIO_MD0);
    tmp_md1 = SYS_RWMEM_W(FPIOA_NIO_MD1);
    switch (nio_mode)
    {
    case NIO_MODE_HIGHZ://00
        tmp_md0 = ~NIO_x & tmp_md0;
        tmp_md1 = ~NIO_x & tmp_md0;
        break;
    case NIO_MODE_OE_PP://10
        tmp_md0 =  NIO_x | tmp_md0;
        tmp_md1 = ~NIO_x & tmp_md1;
        break;
    case NIO_MODE_OE_OD://11
        tmp_md0 =  NIO_x | tmp_md0;
        tmp_md1 =  NIO_x | tmp_md1;
        break;
    default: break;
    }
    SYS_RWMEM_W(FPIOA_NIO_MD0) = tmp_md0;
    SYS_RWMEM_W(FPIOA_NIO_MD1) = tmp_md1;
}

/*********************************************************************
 * @fn      fpioa_nio_mode_read
 *
 * @brief   读取NIOIO端口工作模式
 *
 * @return  NIO工作模式寄存器的值，[63:32]FPIOA_NIO_MD1, [31:0]FPIOA_NIO_MD0
 */
uint64_t fpioa_nio_mode_read()
{
    uint64_t temp;
    temp = (uint64_t)SYS_RWMEM_W(FPIOA_NIO_MD1) << 32;
    temp |= (uint64_t)SYS_RWMEM_W(FPIOA_NIO_MD0);
    return temp;
}