#include "system.h"
/*
IAP - 从SD卡启动
IAP程序在iram低地址，上电后首先执行，把SD/TF卡的文件写入iram高地址
TF卡(microSD)与SD卡通信协议相同，可通用
支持SDv1 v2 SDHC存储卡，必须只有1个分区且格式化为FAT32，根目录只有一个编译生成的bin文件
启动流程如下
1.等待SD卡初始化完成
2.访问MBR分区表(扇区0)
从offset[454,457]小端读取 第一个fat分区的起始扇区号
2.访问fat分区的起始扇区
从offset[11,12]小端读取 每扇区的字节数
从offset[13]读取 每簇的扇区数
从offset[14,15]小端读取 FAT保留扇区数
从offset[16]读取 FAT表个数
从offset[28,31]小端读取 FAT分区前已使用的扇区数
从offset[36,39]小端读取 每个FAT表的扇区数
fat数据区的起始扇区号 = FAT分区前已使用的扇区数 + FAT保留扇区数 + FAT表个数 * 每个FAT表的扇区数
3.访问fat数据区的起始扇区
从offset[181][180][187][186]读取 文件起始簇号
文件起始扇区号 = 数据区的起始扇区号 + (文件起始簇号-2)*每簇的扇区数
从offset[188,191]小端读取 文件大小(字节)
4.访问文件起始扇区
读取数据，可能需要读多个扇区

参考资料
https://www.bilibili.com/video/BV1L64y1o74u/
https://blog.csdn.net/oqqHuTu12345678/article/details/127706775
*/
#define UART0_BAND 115200   //uart0波特率
#define SDRD_DATA(baddr)  SYS_RWMEM_B(sdrd_base_addr + ((baddr)*4))//直接访问SDRD

//全局变量
uint32_t sdrd_base_addr = SDRD_BASE;//SDRD外设基地址
uint32_t uart0_band_val;//uart0波特率分频系数
uint32_t app_base_addr = 16 * 1024;//程序指针

//MBR
#define MBR_PTE_Sector4 454 //小端存储的分区起始扇区号位置
uint32_t fat_base_sector;//fat分区起始扇区号
//fat分区起始
#define FATH_BPS2 11//每扇区的字节数
#define FATH_SPC1 13//每簇的扇区数
#define FATH_FSS2 14//FAT保留扇区数
#define FATH_FTN1 16//FAT表个数
#define FATH_FUS4 28//FAT分区前已使用的扇区数
#define FATH_FTS4 36//每个FAT表的扇区数
uint32_t byte_per_sec;//每扇区的字节数
uint32_t sec_per_clus;//每簇的扇区数
uint32_t fat_save_sector;//FAT保留扇区数
uint32_t fat_tab_number;//FAT表个数
uint32_t fat_used_sector;//FAT分区前已使用的扇区数
uint32_t fat_tab_sector;//每个FAT表的扇区数
uint32_t fat_data_sector;//fat数据区的起始扇区号 = FAT分区前已使用的扇区数 + FAT保留扇区数 + FAT表个数 * 每个FAT表的扇区数
//fat数据区
#define FATD_FBC_0 186//文件起始簇号[0]
#define FATD_FBC_1 187//文件起始簇号[1]
#define FATD_FBC_2 180//文件起始簇号[2]
#define FATD_FBC_3 181//文件起始簇号[3]
#define FATD_FLB4 188//文件大小(字节)
uint32_t file_base_clus;//文件起始簇号
uint32_t file_length_byte;//文件大小(字节)
uint32_t file_base_sector;//文件起始扇区号 = 数据区的起始扇区号 + (文件起始簇号-2)*每簇的扇区数


uint32_t i,j;
uint8_t *str_buffer;
uint8_t *sd_unknow="Unknow";
uint8_t *sd_sdv1="SDv1";
uint8_t *sd_sdv2="SDv2";
uint8_t *sd_sdhc="SDHC";
//读取SD、TF卡的第0，第1扇区
void set_sdrd_sector(uint32_t sector_num);

int main()
{
    uint32_t tmp;

    //初始化uart
    init_uart0_printf(115200,0);//设置波特率
    //替换
    tmp = read_csr(mimpid);
    uart0_band_val = ((tmp & 0x00007FFF) * 10000) / UART0_BAND;//计算波特率分频系数
    tmp = UART_BASE;
    SYS_RWMEM_W(tmp) = 0b0011;//开启UART0
    SYS_RWMEM_W(tmp + 0x08) = uart0_band_val;//设置波特率分频系数

    //等待初始化
    printf("%s", "wait sd init\n");
    while(SYS_RWMEM_B(SDRD_BASE+3) == (uint8_t)0x01);//等待启动完成，等效于while(sdrd_busy_chk());
    tmp = sdrd_init_state_read();
    printf("SDRD state:0x%x \n", tmp);//SD卡版本

    //读取MBR
    set_sdrd_sector(0);//扇区0
    fat_base_sector = SDRD_DATA(MBR_PTE_Sector4+0)\
            + (SDRD_DATA(MBR_PTE_Sector4+1)<<8)\
            + (SDRD_DATA(MBR_PTE_Sector4+2)<<16)\
            + (SDRD_DATA(MBR_PTE_Sector4+3)<<24);//第一个fat分区的起始扇区
    printf("fat_base_sector:%lu\n", fat_base_sector);//第一个fat分区的起始扇区

    //读取FAT分区的起始扇区
    set_sdrd_sector(fat_base_sector);//访问扇区
    byte_per_sec = SDRD_DATA(FATH_BPS2)+(SDRD_DATA(FATH_BPS2+1)<<8);//每扇区的字节数
    sec_per_clus = SDRD_DATA(FATH_SPC1);//每簇的扇区数
    fat_save_sector = SDRD_DATA(FATH_FSS2)+(SDRD_DATA(FATH_FSS2+1)<<8);//FAT保留扇区数
    fat_tab_number = SDRD_DATA(FATH_FTN1);//FAT表个数
    fat_used_sector = SDRD_DATA(FATH_FUS4)+(SDRD_DATA(FATH_FUS4+1)<<8)+(SDRD_DATA(FATH_FUS4+2)<<16)+(SDRD_DATA(FATH_FUS4+3)<<24);//FAT分区前已使用的扇区数
    fat_tab_sector = SDRD_DATA(FATH_FTS4)+(SDRD_DATA(FATH_FTS4+1)<<8)+(SDRD_DATA(FATH_FTS4+2)<<16)+(SDRD_DATA(FATH_FTS4+3)<<24);//每个FAT表的扇区数
    fat_data_sector = fat_used_sector + fat_save_sector + fat_tab_number*fat_tab_sector;//fat数据区的起始扇区号 = FAT分区前已使用的扇区数 + FAT保留扇区数 + FAT表个数 * 每个FAT表的扇区数
    printf("fat_data_sector:%lu\n", fat_data_sector);//fat数据区的起始扇区

    //fat数据区
    set_sdrd_sector(fat_data_sector);//访问扇区
    file_base_clus = SDRD_DATA(FATD_FBC_0)+(SDRD_DATA(FATD_FBC_1)<<8)+(SDRD_DATA(FATD_FBC_2)<<16)+(SDRD_DATA(FATD_FBC_3)<<24);//文件起始簇号
    file_length_byte = SDRD_DATA(FATD_FLB4)+(SDRD_DATA(FATD_FLB4+1)<<8)+(SDRD_DATA(FATD_FLB4+2)<<16)+(SDRD_DATA(FATD_FLB4+3)<<24);//文件大小(字节)
    printf("file_base_clus:%lu\n", file_base_clus);//
    printf("sec_per_clus:%lu\n", sec_per_clus);//
    file_base_sector = fat_data_sector + (file_base_clus-2)*sec_per_clus;//文件起始扇区号 = 数据区的起始扇区号 + (文件起始簇号-2)*每簇的扇区数
    printf("file_base_sector:%lu\n", file_base_sector);//文件的起始扇区
    printf("file_length_byte:%lu\n", file_length_byte);//文件的长度

    //文件区
    set_sdrd_sector(file_base_sector);//访问扇区
    tmp = SDRD_DATA(0)+(SDRD_DATA(0+1)<<8)+(SDRD_DATA(0+2)<<16)+(SDRD_DATA(0+3)<<24);
    printf("app_first byte:0x%x\n", tmp);//文件的长度


}

//设置当前访问的扇区
void set_sdrd_sector(uint32_t sector_num)
{
    SYS_RWMEM_W(SDRD_BASE) = sector_num;//访问扇区
    while(SYS_RWMEM_B(SDRD_BASE+3) == (uint8_t)0x01);//等待结束访问，等效于while(sdrd_busy_chk());
}


