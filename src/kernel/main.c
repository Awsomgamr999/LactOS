void clear_screen(void) {
	volatile char* vga = (volatile char*)0xb8000;
		for (int i = 0; i < 80 * 25; i++) {
			vga[i * 2] = ' ';
			vga[i * 2 + 1] = 0x07;
		}
}

void kernel_main(void) {
	clear_screen();
	
	volatile char* vga = (volatile char*)0xb8000;
	const char* msg = "Kernel Initalized";
	int i = 0;
	while (msg[i] != '\0') {
		vga[i * 2] = msg[i];
		vga[i * 2 + 1] = 0x0a;
		i++;
	}

	while (1) {
		__asm__("hlt");

	}
}

