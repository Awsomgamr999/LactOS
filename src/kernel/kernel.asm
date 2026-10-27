[org 0x1000]
[bits 64]

kernel_entry:
	mov rdx, rdi
	mov rsi, kernel_msg
	mov ah, 0x0f
	
	.print_loop:
		lodsb
		cmp al, 0
		je .done
		mov [rdx], ax
		add rdx, 2
		jmp .print_loop
	
	.done:
		jmp $

kernel_msg: db "Hello Starman! (signed, the kernel)", 0
