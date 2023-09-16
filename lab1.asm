assume CS:code, DS:data

data segment
a dw 5
b dw 4
c dw 3
d dw 3
data ends

code segment
start:
	mov ax, data
	mov ds, ax
	mov ax, b
	mov bx, d
	add ax, bx
	mov cx, a
	mov bx, c
	imul cx
	imul bx
	sub ax, 1
code ends
end start

; a * c * (b + d) - 1
