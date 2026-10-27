[org 0x9000]
[bits 32]

%include "common.inc"

stage3_entry:
	mov ebx, edi
	add edi, 0xb8000
	mov edx, edi
	mov esi, stage3_msg
	mov ah, 0x0f
.print_loop:
		lodsb
		cmp al, 0
		je .calc_newline
		mov [edx], ax
		add edx, 2
		jmp .print_loop
.calc_newline:
		sub edx, 0xb8000
		mov eax, edx
		xor edx, edx
		mov ecx, 160
		div ecx
		inc eax
		mul ecx
		mov ebx, eax

	.setup_long_mode:
		mov edi, 0x10000
		xor eax, eax
		mov ecx, 3072
		rep stosd

		mov dword [0x10000], 0x11000 | 3
		mov dword [0x11000], 0x12000 | 3
		mov dword [0x12000], 0x83

		mov eax, cr4
		or eax, 1 << 5
		mov cr4, eax

		mov eax, 0x10000
		mov cr3, eax

		mov ecx, 0xc0000080
		rdmsr
		or eax, 1 << 8
		wrmsr

		mov eax, cr0
		or eax, 1 << 31
		mov cr0, eax

		lgdt [gdt64_descriptor]
		mov edi, ebx
		jmp CODE64_SEG:stage64_entry

stage3_msg: db "Hello Starman!", 0


[bits 64]

stage64_entry:
	mov ax, DATA64_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov ss, ax
	mov gs, ax

	add rdi, 0xb8000
	mov rsi, stage64_msg
	mov ah, 0x0f
	
	.print64_loop:
		lodsb
		test al, al
		jz .done64
		mov [rdi], ax
		add rdi, 2
		jmp .print64_loop

	.done64:
		
		sub rdi, 0xb8000
		mov rax, rdi
		xor rdx, rdx
		mov rcx, 160
		div rcx
		inc eax
		mul rcx
		add rax, 0xb8000
		mov rdi, rax
		
		mov rax, KERNEL_OFFSET
		jmp rax
	
stage64_msg: db "Welcome to 64 bit.", 0
load_kernel: db "Loading Kernel...", 0


ALIGN 4

gdt64_start:
	dq 0
gdt64_code:
	dw 0xffff
	dw 0x0000
	db 0x00
	db 10011010b
	db 10101111b
	db 0x00
gdt64_data:
	dw 0xffff
	dw 0x0000
	db 0x00
	db 10010010b
	db 00001111b
	db 0x00
gdt64_end:

gdt64_descriptor:
	dw gdt64_end - gdt64_start - 1
	dd gdt64_start

CODE64_SEG equ gdt64_code - gdt64_start
DATA64_SEG equ gdt64_data - gdt64_start

