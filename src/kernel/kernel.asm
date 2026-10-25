[org 0x1000]
[bits 32]

kernel_entry:
	mov edx, 0xb8000 + 480
	mov esi, kernel_msg
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

kernel_msg: db "Hello Starman! (signed, the kernel)", 0
