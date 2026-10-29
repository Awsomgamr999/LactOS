#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>

void init_pit(uint32_t frequency);
uint64_t get_ticks(void);

#endif