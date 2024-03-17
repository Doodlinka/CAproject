; ideal
.model small

.data
	; 0A buffer
	input_max db 1
	input_count db ?
	input_buffer db ?
	
	string_buffer db 16

.stack 10h

.code
main proc
	mov ax, @data
	mov ds, ax

	mov ah, 0Ah
	mov bx, 0
	mov cx, 16
	mov dx, offset input_max
	readLoop:
		; freezes/crashes here when debugging
		int 21h
		; try to test if it read 0 bytes to catch EOF
		mov al, input_count
		test al, al
		jz doneReading
		mov al, [input_buffer]
		mov [string_buffer + bx], al
		inc bx
	loop readLoop
	doneReading:

	mov ax, 4c00h
    int 21h
main endp
end main