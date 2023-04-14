#ifndef _TIMER_H_
#define _TIMER_H_

#include "system.h"

#define SYSIO_BASE           (0x40000000)
#define TIMER0_BASE          (SYSIO_BASE + (0x300))

#define TIMER_CTRL           (TIMER0_BASE + (0x00))
#define TIMER_CMPO           (TIMER0_BASE + (0x04))
#define TIMER_CAPI           (TIMER0_BASE + (0x08))
#define TIMER_TCOF           (TIMER0_BASE + (0x0c))

#define TIMER_TRIG_Z      0b00
#define TIMER_TRIG_P      0b01
#define TIMER_TRIG_N      0b10
#define TIMER_TRIG_D      0b11

void timer_en_ctrl(uint32_t timer_state);
void timer_cmpol_ctrl(uint32_t cmpol);
void timer_capi_trig(uint32_t capi_sel, uint32_t trig_mode);
void timer_div_set(uint32_t diver);
void timer_overflow_set(uint32_t overflow);
void timer_cmpval_set(uint32_t cmp0val, uint32_t cmp1val);
uint32_t timer_cnt_val_read();
uint32_t timer_cap_val_read();

#endif
