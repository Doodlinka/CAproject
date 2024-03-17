; this is documentt in *the book* (switches syntax from MASM to TASM), but doesn't actually work??
; ideal
.model compact

MAX_ID_LEN equ 16

DataPoint struc
	id db 16 dup(?)
	sumOrAverage dd ?
	count dw ?
DataPoint ends

; TODO: I'll have to define two or three extra segments to store the worst-case memory requirement
; model compact may be crucial because it allows several data segments, but apparently it's possible to not go by a model entirely?
; each segment can fit 4096 IDs or 2978 full structs
; refer to pages 21-22 and 447-461 of *the book* for details 
; https://archive.org/details/bitsavers_borlandtureringTurboAssembler2ed1995_80572557/page/446/mode/2up?view=theater
.data
	id_buffer db 16 dup(?)
	bxFor3F dw 0
	cxFor3F dw 1
	input_buffer db ?
	data_arr DataPoint 2500 dup(<>)
	data_arr2 DataPoint 2500 dup(<>)
	data_arr3 DataPoint 2500 dup(<>)
	data_arr4 DataPoint 2500 dup(<>)

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