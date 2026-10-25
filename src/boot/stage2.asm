[org 0x8400]
[bits 16]


%include "common.inc"
start_stage2:
	mov [boot_drive], dl

	mov bx, real_mode_str
	call print16_string
	call print16_newline

enable_a20:
	pusha
	in al, 0x92
	or al, 2
	out 0x92, al
	popa

	mov bx, loading_kernel_str
	call print16_string
	call print16_newline

	mov ax, KERNEL_SEGMENT
	mov es, ax
	mov bx, KERNEL_OFFSET

	mov ax, 0x0209
	mov cx, 0x000c
	mov dh, 0
	mov dl, [boot_drive]
	int 0x13
	
	jc .first_read_error

	
	mov ax, KERNEL_SEGMENT
	mov es, ax
	mov bx, KERNEL_OFFSET + (9 * 512)
	
	mov ax, 0x0207
	mov cx, 0x0001
	mov dh, 1
	mov dl, [boot_drive]
	int 0x13
	jc .second_read_error

	; loading stage3.asm
	mov ax, 0x0000
	mov es, ax
	mov bx, stage3_address

	mov ah, 0x02
	mov al, stage3_sectors
	mov ch, 0
	mov cl, 10
	mov dh, 0
	mov dl, [boot_drive]
	int 0x13
	jc .disk_error


	mov dword [cursor_pos], VGA_THIRD_LINE_OFFSET
	call switch_to_pm

	.first_read_error:
		mov bx, first_read_error_str
		call print16_string
		call print16_newline
		jmp $
	
	.second_read_error:
		mov bx, second_read_error_str
		call print16_string
		call print16_newline
		jmp $
	.disk_error:
		mov bx, disk_error
		call print16_string
		call print16_newline
		jmp $

print16_string:
	pusha
	mov si, bx
	.print16_loop:
		lodsb
		cmp al, 0
		je .end_print16_loop

		mov ah, 0x0e
		mov bh, 0
		mov bl, 0x07
		int 0x10
		jmp .print16_loop
	.end_print16_loop:
		popa
		ret

print16_newline:
	pusha

	mov ah, 0x0e
	mov al, 0x0d
	int 0x10

	mov al, 0x0a
	int 0x10
	
	popa
	ret
	
[bits 16]

gdt_start:
	gdt_null:
		dd 0x00000000
		dd 0x00000000

	gdt_code:
		dw 0xffff
		dw 0x0000
		db 0x00
		db 10011010B
		db 11001111B
		db 0x00

	gdt_data:
		dw 0xffff
		dw 0x0000
		db 0x00
		db 10010010B
		db 11001111B
		db 0x00

	gdt_end:

	gdt_descriptor:
		dw gdt_end - gdt_start - 1
		dd gdt_start

		CODE_SEG equ gdt_code - gdt_start
		DATA_SEG equ gdt_data - gdt_start

[bits 16]

switch_to_pm:
	cli
	lgdt [gdt_descriptor]

	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	jmp CODE_SEG:init_pm


[bits 32]


init_pm:
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, 0x90000
	mov esp, ebp

	call begin_pm

begin_pm:
	mov ebx, protected_mode_str
	call print32_string
	call print32_newline

	;jmp CODE_SEG:KERNEL_OFFSET
	jmp CODE_SEG:stage3_address

print32_string:
	pusha
	mov esi, ebx
	mov edi, [cursor_pos]
	add edi, 0xb8000
	mov ah, 0x0f
.print32_loop:
	lodsb
	cmp al, 0
	je .done
	mov [edi], ax
	add edi, 2
	jmp .print32_loop
.done:
	mov [cursor_pos], edi
	sub dword [cursor_pos], 0xb8000
	popa
	ret
print32_newline:
	; make this later
	ret

boot_drive:		db 0
cursor_pos:		dd 0

real_mode_str:		db "Currently 16 bit RM", 0
loading_kernel_str:	db "Loading Kernel", 0
protected_mode_str:	db "Successfully in 32 bit PM", 0
disk_error_str:		db "Disk read error! Test 123", 0
first_read_error_str:	db "Disk read 1 error!", 0
second_read_error_str:	db "Disk read 2 error!", 0
disk_error:		db "Disk Read Error", 0

times 4096 - ($ - $$) db 0
