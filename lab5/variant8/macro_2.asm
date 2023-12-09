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

solve macro string, result
    local search_first_symbol, search_spaces, insert_space, need_to_insert_space, continue, insert_symb, continue_macro

    mov si, offset string
    inc si
    inc si
    mov di, offset result

    search_first_symbol:
        mov al, [si]
        cmp al, '$'
            je continue_macro
        cmp al, ' '
            jne search_spaces
        inc si
        jmp search_first_symbol
        
    search_spaces:

        mov al, [si]
        cmp al, '$'
            je continue_macro
        cmp al, ' '
            je insert_space
            jne insert_symb
        inc si
        jmp search_spaces

    insert_space:
        mov al, [si - 1]

        cmp al, ' '
            jne need_to_insert_space
            je continue

        need_to_insert_space:
            mov bl, ' '
            mov [di], bl
            inc di
        continue:
            inc si
            jmp search_spaces

    insert_symb:

        mov [di], al
        inc di
        inc si
        jmp search_spaces

    continue_macro:
        xor ax, ax
endm
