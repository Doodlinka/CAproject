.model small

.data
	id db 16 dup (?)

.stack 10h

.code
main proc
	mov ax, @data
	mov ds, ax

	mov bx, 0
	mov cx, 16
	mov ah, 01h
	readLoop:
		int 21h
		mov [id + bx], al
		inc bx
	loop readLoop
	
	mov bx, 0
	mov cx, 16
	mov ah, 02h
	mov dl, 0Dh
	int 21h
	writeLoop:
		mov dl, [id + bx]
		int 21h
		inc bx
	loop writeLoop

	mov ax, 4c00h
    int 21h
main endp
end main