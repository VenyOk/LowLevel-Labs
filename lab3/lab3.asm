assume CS:code, DS:data
data segment
    dummy db 0Dh, 0Ah, '$'
    str1 db 100, 101 dup ('$')
    str2 db 100, 101 dup ('$')
    buf db 11 dup(' ') , '$'
data ends


;  РЕАЛИЗАЦИЯ ФУНКЦИИ STRCMP



code segment
strcmp proc
    push bp
    mov bp, sp
	
    mov si, [bp+4]
    mov di, [bp+6]

compare_loop:
    mov al, [si]   ; Загрузка символа из первой строки
    mov bl, [di]   ; Загрузка символа из второй строки
    cmp al, bl
    jne not_equal 

    
    cmp al, '$'    
    je equal_A      
	cmp bl, '$'
	je equal_B
    
    inc si
    inc di
    jmp compare_loop

not_equal:
    cmp al, bl
    jl less_than   
    jg greater_than 

equal_A:
	cmp bl, '$'
	je zero
	jmp greater_than
	
equal_B:
	cmp al, '$'
	je zero
	jmp less_than

zero:    
	mov ax, 0       
    jmp done
	
less_than:
    mov ax, -1      
    jmp done

greater_than:
    mov ax, 1       
    jmp done

done:
    pop bp
    ret

strcmp endp

print_result proc
	cmp ax, -1
	je minus
	jmp print
	
	
	minus:
		mov dl, 45
		mov ah, 2
		int 21h
		mov ax, 1
		jmp print
	
	print:
		mov cx, 10
		mov di, offset buf + 10

		convertLoop:
			xor dx, dx
			div cx
			add dl, '0'
			dec di
			mov [di], dl
			cmp ax, 0
			jnz convertLoop

			mov dx, offset buf
			mov ah, 09h
			lea dx, [di]
			int 21h
			ret
print_result endp

start:
    mov ax, data
    mov ds, ax

    ; Ввод первой строки
    mov dx, offset str1
    mov ah, 0Ah
    int 21h

    mov dx, offset dummy ; перевод строки
    mov ah, 09h
    int 21h
    mov dx, offset str2
    ; Ввод второй строки
    mov ah, 0Ah
    int 21h
    mov dx, offset dummy ; перевод строки
    mov ah, 09h
    int 21h

    push offset str2
    push offset str1
	
	
    call strcmp
	call print_result
	

    mov ah, 4Ch
    int 21h
code ends
end start
