
assume cs: code, ds: data

data segment
    dummy db 0Ah, "$" 
    string db 100, 99 dup ('$')
    max_len dw 12
    num1 db 100, 99 dup (0) 
    num2 db 100, 99 dup (0) 
    result db 100, 99 dup (0) 
    notation db 10
    cmpres db 0

    ; error
    bad_symbol db 100, " Error: bad symbol $"
data ends

code segment



macroless macro a, b, endmark
    cmp a, b
    jge endmark
endm



strlen macro str, reg
    xor reg&x, reg&x
    mov reg&l, str[1]
endm

tohex proc
    mov cl, 60h
    macroless cl, ch, tohexendif
        sub ch, 'a'
        add ch, ':'
    tohexendif:
    ret
tohex endp

fromhex proc
    mov cl, '9'
    macroless cl, ch, fromhexendif
        sub ch, ':'
        add ch, 'a'
    fromhexendif:
    ret
fromhex endp

numtostring proc
    mov bp, sp
    mov si, [bp + 2] 
    mov ax, max_len
    xor di, di 
    
    add si, max_len
    mov bl, [si]
    cmp bx, 0
    je plus
        push ax
        push dx
        mov ah, 2
        mov dl, '-'
        int 21h
        pop dx
        pop ax
        jmp endsign
    plus:
        push ax
        push dx
        mov ah, 2
        mov dl, '+'
        int 21h
        pop dx
        pop ax
    endsign:
    sub si, max_len

    mov bx, 2
    loop_numtostring:
        mov ch, [si]
        add ch, '0'
        
        call fromhex
        mov string[bx], ch

        inc si
        inc di
        inc bx
        macroless di, ax, break_numtostring
            jmp loop_numtostring
        break_numtostring:
    ret
numtostring endp



tonum proc
    mov bp, sp
    mov di, [bp + 2] 
    strlen string, a 
    mov bx, max_len
    sub bx, ax  
    add ax, 2
    mov si, 2 
    xor dx, dx
    mov [di], dx 
    loop_tonum:
        mov ch, string[si]
        
        call tohex
        
        
        push ax
        mov al, '/'
        mov ah, '0'
        add ah, notation
        macroless ch, ah, _&endmark&
        macroless al, ch, _&endmark&
            pop ax
            jmp ok_it_is_number
        _&endmark&:   
        pop ax

        push ax
        push bx
        mov ah, '-'
        mov bh, ch
        cmp bh, ah
        pop bx
        pop ax
        je minus_case

            push ax
            mov ah, 09h
            lea dx, bad_symbol
            add dx, 2 
            int 21h
            pop ax

            jmp endprogram
        ok_it_is_number:


        jmp number_case
        minus_case:
            push ax
            add di, max_len
            mov ax, [di]
            not ax
            mov [di], ax
            sub di, max_len
            pop ax
            jmp endcase
        number_case:
            sub ch, '0'
            mov [di + bx], ch
        endcase:

        inc si
        inc bx
        macroless si, ax, break_tonum
            jmp loop_tonum
        break_tonum:
    ret
tonum endp

invert macro num
    push di
    push ax
    mov di, max_len
    mov al, num[di]
    not al
    mov num[di], al
    pop ax
    pop di
endm

swap_nums proc
    push si
    push ax
    push bx
    mov si, max_len 
    dec si
    loop_swap:
        mov al, num1[si]
        mov bl, num2[si]
        mov num1[si], bl
        mov num2[si], al

        dec si
        cmp si, 0
        je break_swap
        jmp loop_swap
    break_swap:    
    pop bx
    pop ax
    pop si
    ret
swap_nums endp

compare_nums proc
    push di
    push ax
    push bx    
    xor ax, ax
    xor bx, bx
    xor si, si

    
    mov di, max_len
    mov al, num1[di]
    mov bl, num2[di]

    cmp ax, bx
    je loop_comp
    jl sign_less
        mov cmpres, 2        
        jmp endcompare_nums
    sign_less:
        mov cmpres, 1
        jmp endcompare_nums
    
    loop_comp:
        mov al, num1[si]
        mov bl, num2[si]
        cmp ax, bx
        je cmp_equal
        jl equal_less
            mov cmpres, 1
            jmp break_comp
        equal_less:
            mov cmpres, 2
            jmp break_comp
        cmp_equal:

        inc si
        cmp si, max_len
        jge break_comp
        jmp loop_comp
    break_comp:


    endcompare_nums:
    pop bx
    pop ax
    pop di
    ret
compare_nums endp


count_sum proc
    
    mov di, max_len
    mov al, num1[di]
    mov bl, num2[di]
    cmp al, bl
    je skipdiff
        invert num2
        call count_diff
        ret
    skipdiff:

    
    call compare_nums
    cmp cmpres, 2
    jne not_swap_
        call swap_nums
    not_swap_:

    mov di, max_len
    mov al, num1[di]
    cmp al, 0
    je invert_in_diff_
        invert result
    invert_in_diff_:

    mov si, max_len
    sub si, 1
    loop_sum:
        
        xor cx, cx
        mov ah, num1[si]
        mov bh, num2[si]
        mov ch, result[si]

        add ch, ah
        add ch, bh
        
        
        mov cl, notation
        dec cl
        macroless cl, ch, sum_overflow
            
            sub ch, notation
            
            mov cl, 1
            mov result[si - 1], cl
        sum_overflow:

        mov result[si], ch

        dec si
        cmp si, 0
        jl break_sum
        jmp loop_sum
    break_sum:
    ret
count_sum endp

count_diff proc
    
    mov di, max_len
    mov al, num1[di]
    mov bl, num2[di]
    cmp al, bl
    je skipsum
        invert num2
        call count_sum
        ret
    skipsum:

    
    call compare_nums
    cmp cmpres, 2
    jne not_swap
        call swap_nums
        invert result
    not_swap:

    mov di, max_len
    mov al, num1[di]
    cmp al, 0
    je invert_in_diff
        invert result
    invert_in_diff:

    mov si, max_len
    sub si, 1
    xor dh, dh 

    loop_diff:
        
        xor cx, cx
        mov ah, num1[si]
        mov bh, num2[si]

        add ch, ah
        sub ch, bh
        sub ch, dh
        
        xor cl, cl 
        xor dh, dh 
        macroless ch, cl, diff_overflow
            
            add ch, notation
            
            mov dh, 1
            
        diff_overflow:

        mov result[si], ch

        dec si
        cmp si, 0
        jl break_diff
        jmp loop_diff
    break_diff:
    ret
count_diff endp

count_prod proc
    mov di, max_len
    sub di, 1
    xor bx, bx
    
    loop_sumprod:
        mov si, max_len
        sub si, 1
        loop_prod:
           
            xor ax, ax
            xor cx, cx
            xor dx, dx
            mov al, num1[si]
            mov dl, num2[di]
            
            
            mul dx
            
        
            mov cl, notation
            div cl
            
            sub si, bx
            add result[si - 1], al
            add result[si], ah
            add si, bx

            dec si
            cmp si, 0
            jl break_prod
            jmp loop_prod
        break_prod:

        inc bx
        dec di
        cmp di, 0
        jl break_sumprod
        jmp loop_sumprod
    break_sumprod:

    mov di, max_len
    sub di, 1
    loop_fix:
    
        xor ax, ax
        mov cl, notation
        mov al, result[di]
        div cl
        
        add result[di - 1], al
        mov result[di], ah

        dec di
        cmp di, 0
        jl break_fix
        jmp loop_fix
    break_fix:


    mov di, max_len
    push ax
    push bx
    mov al, num1[di]
    mov bl, num2[di]
    xor al, bl
    mov result[di], al
    pop bx
    pop ax
    ret
count_prod endp

start:
    mov ax, data
    mov ds, ax


    mov dx, offset string
    
    xor ax, ax
    mov ah, 0Ah
    int 21h
    

    mov si, dx
    xor bh, bh
    mov bl, [si+1]
    mov ch, '$'
    add bx, 2
    mov [si+bx], ch

    mov dx, offset dummy
    mov ah, 09h
    int 21h
    mov dx, offset num1
    push dx
    call tonum

    mov dx, offset string
    
    xor ax, ax
    mov ah, 0Ah
    int 21h
    

    mov si, dx
    xor bh, bh
    mov bl, [si+1]
    mov ch, '$'
    add bx, 2
    mov [si+bx], ch

    mov dx, offset dummy
    mov ah, 09h
    int 21h
    mov dx, offset num2
    push dx
    call tonum


    xor dx, dx
    mov result[0], dh



    ;call count_sum
    ;call count_diff
    call count_prod

    ; Вывод результата на экран    
    mov dx, offset result
    push dx
    call numtostring

    push ax
    mov ah, 09h
    lea dx, string
    add dx, 2 
    int 21h
    pop ax

    push ax
    mov ah, 09h
    lea dx, dummy
    int 21h
    pop ax
    
    endprogram:
        mov ah, 4Ch
        int 21h
code ends
end start
