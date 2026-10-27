; common definitions between files.

%define load_address		0x7c00
%define relocate_address	0x7e00
%define sector_size		512
%define stage2_sectors		8
%define stage2_address		0x8400
%define offset_reloc (relocate_address - load_address)
%define KERNEL_OFFSET	0x1000
%define KERNEL_SEGMENT	0x0000
%define KERNEL_SECTORS	16
%define VGA_THIRD_LINE_OFFSET	480
VIDEO_MEMORY	equ 0xb8000
WHITE_ON_BLACK	equ 0x0f

%define stage3_address		0x9000
%define stage3_sectors		2

%define MEMORY_MAP_BUFFER	0x7e00
%define MEMORY_MAP_COUNT	0x7df0
