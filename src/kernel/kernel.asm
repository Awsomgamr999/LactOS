[org 0x1000]
[bits 64]

kernel_entry:
	mov rdx, rdi
	mov rsi, kernel_msg
	mov ah, 0x0f
	
	.print_loop:
		lodsb
		cmp al, 0
		je .calc_next_line
		mov [rdx], ax
		add rdx, 2
		jmp .print_loop
	
	.calc_next_line:
		sub rdx, 0xb8000
		mov rax, rdx
		xor rdx, rdx
		mov rcx, 160
		div rcx
		inc eax
		mul rcx
		add rax, 0xb8000
		mov rdi, rax

		xor r8, r8
		movzx rcx, word [0x7df0]
		mov rbx, 0x7e00

	.parse_loop:
		test rcx, rcx
		jz .done_parsing

		mov eax, dword [rbx + 16]
		cmp eax, 1
		jne .skip_entry

		mov rax, qword [rbx + 8]
		add r8, rax

	.skip_entry:
		add rbx, 24
		dec rcx
		jmp .parse_loop

	.done_parsing:
		mov rax, r8
		shr rax, 20

		mov rsi, ram_msg
		mov rdx, rdi
		mov ah, 0x0f
	
	.print_ram_msg:
		lodsb
		cmp al, 0
		je .setup_number_print
		mov [rdx], ax
		add rdx, 2
		jmp .print_ram_msg

	.setup_number_print:
		mov r9, rdx
		mov rax, r8
		shr rax, 20
		mov rcx, 10
		mov rbx, temp_str + 15
		mov byte [rbx], 0

	.convert_loop:
		xor rdx, rdx
		div rcx
		add dl, '0'
		dec rbx
		mov [rbx], dl
		test rax, rax
		jnz .convert_loop
		mov rdx, r9
		mov rsi, rbx
		mov ah, 0x0f
	
	.print_num_loop:
		lodsb
		cmp al, 0
		je .print_mb_suffix
		mov [rdx], ax
		add rdx, 2
		jmp .print_num_loop

	.print_mb_suffix:
		mov rsi, mb_msg
		mov ah, 0x0f
	
	.print_mb_loop:
		lodsb
		cmp al, 0
		je .done
		mov [rdx], ax
		add rdx, 2
		jmp .print_mb_loop

	.done:
		jmp $

kernel_msg: db "Hello Starman! (signed, the kernel)", 0
ram_msg: db "Detected usable RAM: ", 0
mb_msg: db " MB", 0

section .bss
temp_str: resb 16
