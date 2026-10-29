#include <stdint.h>

static inline void outb(uint16_t port, uint8_t val) {
	__asm__ volatile ("outb %0, %w1" : : "a"(val), "Nd"(port));
}
volatile uint64_t global_ticks = 0;

void init_pit(uint32_t frequency) {
	uint32_t divisor = 1193182 / frequency;

	outb(0x43, 0x36);

	outb(0x40, (uint8_t)(divisor & 0xff));
	outb(0x40, (uint8_t)((divisor >> 8) & 0xff));
}

void timer_handler_main(void) {
	global_ticks++;
}

uint64_t get_ticks(void) {
	return global_ticks;
}
	
