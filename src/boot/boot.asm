[org 0x7c00]
[bits 16]


%include "common.inc"

; start booting
start_boot:
	cli
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, load_address

	mov [boot_drive], dl
	sti

	mov si, load_address
	mov di, relocate_address
	mov cx, sector_size
	cld
	rep movsb

	jmp 0x0000:(continue_boot + offset_reloc)

continue_boot:
	call clear_screen

	mov ah, 0x02
	mov al, stage2_sectors
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, [boot_drive + offset_reloc]
	mov bx, stage2_address
	int 0x13

	jc disk_error
	cmp al, stage2_sectors
	jne disk_error
	jmp stage2_loaded_success

disk_error:
	mov bx, disk_error_str + offset_reloc
	call print16_string
	call print16_newline
	jmp $

stage2_loaded_success:
	mov bx, stage2_loaded_str + offset_reloc
	call print16_string
	call print16_newline

	mov dl, [boot_drive + offset_reloc]
	jmp 0x0000:stage2_address

clear_screen:
	pusha
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	popa
	ret

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

stage2_loaded_str: db "Stage 2 successfully loaded!", 0
disk_error_str: db "Error: Disk read error!", 0
system_halted_str: db "System halted!", 0

boot_drive: db 0







times 446 - ($-$$) db 0
times 64 db 0
dw 0xaa55
