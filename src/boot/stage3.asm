[org 0x9000]
[bits 32]

stage3_entry:
	mov edx, 0xb8000 + 480
	mov esi, stage3_msg
	mov ah, 0x0f
	
	.print_loop:
		lodsb
		cmp al, 0
		je .done
		mov [edx], ax
		add edx, 2
		jmp .print_loop
	
	.done:
		jmp $

stage3_msg: db "Hello Starman! (signed, stage3.asm)", 0
