#include "../include/idt.h"

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

#define PIC1_COMMAND 0x20
#define PIC1_DATA    0x21
#define PIC2_COMMAND 0xA0
#define PIC2_DATA    0xA1

struct idt_entry idt[256];
struct idt_ptr idtr;

static void remap_pic(void) {
    uint8_t a1 = inb(PIC1_DATA);
    uint8_t a2 = inb(PIC2_DATA);

    outb(PIC1_COMMAND, 0x11);
    outb(PIC2_COMMAND, 0x11);

    outb(PIC1_DATA, 0x20); // Master offset 0x20
    outb(PIC2_DATA, 0x28); // Slave offset 0x28

    outb(PIC1_DATA, 0x04);
    outb(PIC2_DATA, 0x02);

    outb(PIC1_DATA, 0x01);
    outb(PIC2_DATA, 0x01);

    outb(PIC1_DATA, 0xFC); 
    outb(PIC2_DATA, 0xFF);
}

extern void isr_stub_timer(void);

void set_idt_gate(int vector, uint64_t handler) {
    idt[vector].offset_low  = (uint16_t)(handler & 0xFFFF);
    idt[vector].selector    = 0x08;
    idt[vector].ist         = 0;
    idt[vector].type_attr   = 0x8E;
    idt[vector].offset_mid  = (uint16_t)((handler >> 16) & 0xFFFF);
    idt[vector].offset_high = (uint32_t)(handler >> 32);
    idt[vector].reserved    = 0;
}

extern void isr_stub_keyboard(void);

void init_idt(void) {
    idtr.limit = sizeof(struct idt_entry) * 256 - 1;
    idtr.base  = (uint64_t)&idt;

    remap_pic();

    set_idt_gate(0x20, (uint64_t)isr_stub_timer);
    set_idt_gate(0x21, (uint64_t)isr_stub_keyboard);

    __asm__ volatile ("lidt %0" : : "m"(idtr));
    __asm__ volatile ("sti");
}
