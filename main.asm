; ideal
.model small

; struc DataPoint
; 	id db 16 dup ?
; 	sumOrAverage dd ?
; 	count dw ?
; ends DataPoint

.data
	id_buffer db 16 dup(?)
	bxFor3F dw 0
	cxFor3F dw 1
	input_buffer db ?

.stack 10h

.code
main proc
	mov ax, @data
	mov ds, ax

	mov dx, offset input_buffer
	mov bx, 0
	mov cx, 16
	readLoop:
		; https://www.stanislavs.org/helppc/int_21-3f.html
		mov ah, 3Fh
		xchg bx, [bxFor3F]
		xchg cx, [cxFor3F]
		int 21h
		; check for EOF
		test ax, ax
		jz doneReading
		; restore our values
		mov al, [input_buffer]
		xchg bx, [bxFor3F]
		xchg cx, [cxFor3F]
		; put the char into the buffer
		mov [id_buffer + bx], al
		; move on to the next iteration
		inc bx
	loop readLoop
	doneReading:

	mov ax, 4c00h
    int 21h
main endp
end main