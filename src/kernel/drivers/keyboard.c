#include <stdint.h>
#include "../include/keyboard.h"

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static const char scancode_ascii[128] = {
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

int keyboard_cursor_offset = 0;

void keyboard_handler_main(void) {
    uint8_t scancode = inb(0x60);

    volatile char* vga = (volatile char*)0xb8000;
    vga[158] = 'X';
    vga[159] = 0x0C;

    if (!(scancode & 0x80)) {
        char ascii = 0;
        if (scancode < 128) {
            ascii = scancode_ascii[scancode];
        }

        if (ascii != 0) {
            if (ascii == '\b') {
                if (keyboard_cursor_offset > 336) {
                    keyboard_cursor_offset -= 2;
                    vga[keyboard_cursor_offset] = ' ';
                    vga[keyboard_cursor_offset + 1] = 0x07;
                }
            } else if (ascii == '\n') {
                keyboard_cursor_offset = ((keyboard_cursor_offset / 160) + 1) * 160;
            } else {
                vga[keyboard_cursor_offset] = ascii;
                vga[keyboard_cursor_offset + 1] = 0x0F;
                keyboard_cursor_offset += 2;
            }

            if (keyboard_cursor_offset >= 4000) {
                keyboard_cursor_offset = 0; 
            }
        }
    }
}