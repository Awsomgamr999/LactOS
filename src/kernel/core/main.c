#include <stdint.h>
#include "../include/idt.h"
#include "../include/keyboard.h"

struct __attribute__((packed)) e820_entry {
	uint64_t base_addr;
    uint64_t length;
	uint32_t type;
	uint32_t acpi_ext;
};

void clear_screen(void) {
	volatile char* vga = (volatile char*)0xb8000;
		for (int i = 0; i < 80 * 25; i++) {
			vga[i * 2] = ' ';
			vga[i * 2 + 1] = 0x07;
		}
}

int print_string(int offset, const char* str, char color) {
    volatile char* vga = (volatile char*)(0xb8000 + offset);
    int i = 0;
    while (str[i] != '\0') {
        vga[i * 2] = str[i];
        vga[i * 2 + 1] = color;
        i++;
    }
    return offset + (i * 2);
}

int print_number(int offset, uint64_t num, char color) {
    char buf[32];
    int idx = 31;
    buf[idx] = '\0';
    
    if (num == 0) {
        buf[--idx] = '0';
    } else {
        while (num > 0) {
            buf[--idx] = '0' + (num % 10);
            num /= 10;
        }
    }
    return print_string(offset, &buf[idx], color);
}



void kernel_main(void) {
	clear_screen();
	
	int cursor = 0;
	cursor = print_string(cursor, "Hello Starman", 0x0a);

	cursor = 160;

	uint16_t entry_count = *(volatile uint16_t*)0x7df0;
	struct e820_entry* entries = (struct e820_entry*)0x7e00;

	uint64_t total_ram_bytes = 0;
	for (uint16_t i = 0; i < entry_count; i++) {
		if (entries[i].type == 1) {
			total_ram_bytes += entries[i].length;
		}
	}

	uint64_t total_ram_mb = total_ram_bytes / (1024 * 1024);

	cursor = print_string(cursor, "Total RAM: ", 0x0f);
	cursor = print_number(cursor, total_ram_mb, 0x0f);
	cursor = print_string(cursor, " MB", 0x0f);
	
	cursor = 320;
	cursor = print_string(cursor, "LactOS> ", 0x0f);
	
	keyboard_cursor_offset = cursor;
	
	init_idt();

	while (1) {
		__asm__("hlt");

	}
}

