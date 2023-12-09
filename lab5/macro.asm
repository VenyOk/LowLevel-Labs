print macro string

    xor ax, ax
	mov dx, offset string
	mov ah, 09h
	int 21h

endm

input macro string

	xor ax, ax
	mov ah, 0ah
	lea dx, string
	int 21h

endm


solve macro string, symb, result
	local search_symb_loop, found, continue, enter_symb, need_to_move_loop, part_of_loop, plus_si, not_to_move, not_to_move_loop, end_macros

    xor ax, ax
    mov si, offset string
    mov cx, 0
    add si, 2

    search_symb_loop:
        mov al, [si]
		cmp al, '$'
			je not_to_move
        cmp al, symb[2]
        je found
        inc si
        inc cx
        jmp search_symb_loop

	xor ax, ax
	jmp continue

    found:
		xor ax, ax
        mov ah, 1

    continue:

        cmp ah, 1
        je enter_symb
        jne not_to_move

	enter_symb:

		mov di, offset result
		mov al, symb[2]
		mov [di], al
		mov si, offset string
		add si, 2
		inc di
		xor ax, ax

    need_to_move_loop:

		mov al, [si]
		cmp al, '$'
			je end_macros
		mov [di], al
		cmp cx, 0
			je plus_si
		part_of_loop:
			dec cx
			inc si
			inc di
			jmp need_to_move_loop

	plus_si:
		dec di
		jmp part_of_loop

	not_to_move:

		mov di, offset result
		mov si, offset string
		add si, 2
		xor ax, ax
		not_to_move_loop:
			mov al, [si]
			mov [di], al
			inc si
			inc di
			cmp al, '$'
				je end_macros
			jmp not_to_move_loop

    end_macros:
        xor ax, ax
endm
