assume CS:code, DS:data

data segment
    a dw 1
    b dw 2
    c dw 107
    d dw 2
    buf db 11 dup(' ') , '$'
    number dw 0
data ends

code segment
start:
    mov ax, data
    mov ds, ax

    mov ax, b
    mov bx, d
    add ax, bx
    imul c
    imul a
    sub ax, 1
    mov bx, ax
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
; Вывод в шестнадцатеричной системе счисления    
    mov ax, bx
    mov di, offset buf + 10
    mov cx, 16

convertLoop2:
    xor dx, dx
    div cx
    cmp dl, 10
    jb digit
    sub dl, 10
    add dl, 'A'
    jmp next

digit:
    add dl, '0'

next:
    dec di
    mov [di], dl
    cmp ax, 0
    jnz convertLoop2
mov ah, 09h  
lea dx, [di]  
int 21h

mov ah, 4Ch
int 21h

code ends
end start
