[bits 64]

global kernel_entry
extern kernel_main

section .text
kernel_entry:
	mov rsp, 0x90000
	mov rbp, rsp
	
	cld
	call kernel_main

.hang:
	cli
	hlt
	jmp .hang
