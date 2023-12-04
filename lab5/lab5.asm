include macro.asm

assume cs:code, ds:data
data segment
    dummy db 0Dh, 0Ah, '$'
    string db 100, 101 dup ('$')
    symb db 100, 101 dup ('$')
    result db 100 dup ('$')
data ends



code segment
start:
    mov ax, data
    mov ds, ax

    input string
    print dummy
    input symb
    print dummy


    solve string symb result

    print result

    mov ah, 4Ch
    int 21h
code ends
end start
