assume CS:code, DS:data

data segment
    arr dw 12, 10, 7, 3, 5, 4, 21, 9, 40, 15, 46
    len dw 11
    buf db 11 dup(' ') , '$'
    elem dw 9
data ends
; Вычислить индекс заданного элемента массива
code segment
start:
    mov ax, data
    mov ds, ax
    mov cx, len     
    mov si, 0
find_elem:
	mov ax, arr[si]
	
    cmp ax, elem         
    je done          

    add si, 2
    loop find_elem

done:
	mov ax, len
	sub ax, cx
	
	; Вывод в десятичной системе счисления
    mov di, offset buf + 10 
    mov cx, 10

convertLoop: 
    xor dx, dx
    div cx
    add dl, '0'
    dec di
    mov [di], dl
    cmp ax, 0
    jnz convertLoop

    mov ah, 09h  
    lea dx, [di]  
    int 21h
	
	mov ah, 4Ch
	int 21h

code ends
end start
