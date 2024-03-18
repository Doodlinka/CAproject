; this is documented in *the book* (switches syntax from MASM to TASM), but doesn't actually work??
; ideal
.model compact

MAX_DATA_AMOUNT equ 10000
MAX_ID_LEN equ 16

DataPoint struc
	sumOrAverage dd ?
	count dw ?
	id_addr dw ?
DataPoint ends

; TODO: I'll have to define two or three extra segments to store the worst-case memory requirement
; model compact may be crucial because it allows several data segments, but apparently it's possible to not go by a model entirely?
; each segment can fit 4096 IDs, 8192 values, or 2978 full structs
; refer to pages 21-22 and 447-461 of *the book* for details 
; https://archive.org/details/bitsavers_borlandtureringTurboAssembler2ed1995_80572557/page/446/mode/2up?view=theater
.data
	bxFor3F dw 0
	cxFor3F dw 1
	current_id db MAX_ID_LEN dup(?)
	input_buffer db ?

.stack 256

; it says "location counter overlow", but this is exactly 64KB, and it looks fine on the map
segment valueSegment
	values DataPoint 8192 dup(<>)
ends valueSegment

segment valueSegment2
	values2 DataPoint MAX_DATA_AMOUNT - 8192 dup(<>)
ends valueSegment2

; I can't say the number 65536, I have to define separate names or use a bigger type instead
segment idSegment
	ids db 65535 dup(?)
	last_id_byte db ?
ends idSegment

segment idSegment2
	ids2 db 65535 dup(?)
	last_id_byte2 db ?
ends idSegment2

segment idSegment3
	ids3 db (MAX_DATA_AMOUNT - 8192) * 16 dup(?)
ends idSegment3


.code
main proc
	mov ax, @data
	mov ds, ax

	mov dx, offset input_buffer
	mov bx, 0
	mov cx, MAX_ID_LEN
	readLoop:
		call getChar
		jz doneReading
		; put the char into the buffer
		mov [current_id + bx], al
		; move on to the next iteration
		inc bx
	loop readLoop
	doneReading:

	mov ax, 4c00h
    int 21h
main endp

getChar proc
	; https://www.stanislavs.org/helppc/int_21-3f.html
	mov ah, 3Fh
	xchg bx, [bxFor3F]
	xchg cx, [cxFor3F]
	int 21h
	; check for EOF
	test ax, ax
	jz endGetChar
	; restore our values
	mov al, [input_buffer]
	xchg bx, [bxFor3F]
	xchg cx, [cxFor3F]
	endGetChar: ret
getChar endp

readValue proc

readValue endp

cmpCurrent proc

cmpCurrent endp

end main