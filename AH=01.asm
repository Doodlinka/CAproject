; ideal
.model small

.data
	string_buffer db 16

.stack 10h

.code
main proc
	mov ax, @data
	mov ds, ax

	; https://www.stanislavs.org/helppc/int_21-1.html
	mov ah, 01h
	mov bx, 0
	mov cx, 16
	readLoop:
		int 21h
		mov [string_buffer + bx], al
		inc bx
	loop readLoop

	mov ax, 4c00h
    int 21h
main endp
end main