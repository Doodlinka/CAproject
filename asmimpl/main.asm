ideal
p286
p287
model compact

MAX_DATA_AMOUNT equ 10000
MAX_ID_LEN equ 16
LF equ 13

struc DataPoint
	sumOrAverage dd ?
	count dw ?
	id_addr dw ?
ends DataPoint

; TODO: I'll have to define two or three extra segments to store the worst-case memory requirement
; model compact may be crucial because it allows several data segments, but apparently it's possible to not go by a model entirely?
; each segment can fit 4096 IDs, 8192 values, or 2978 full structs
; refer to pages 21-22 and 447-461 of *the book* for details 
; https://archive.org/details/bitsavers_borlandtureringTurboAssembler2ed1995_80572557/page/446/mode/2up?view=theater
dataseg
	bxFor3F dw 0
	cxFor3F dw 1

udataseg
	current_id db MAX_ID_LEN dup(?)
	input_buffer db ?

stack 256

; it says "location counter overlow", but this is exactly 64KB, and it looks fine on the map
segment valueSegment
	values DataPoint 8192 dup(<>)
ends valueSegment

segment valueSegment2
	values2 DataPoint MAX_DATA_AMOUNT - 8192 dup(<>)
ends valueSegment2

; I can't use the number 65536, I have to define separate names or use a bigger type instead
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


codeseg
proc main
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
endp main

proc getChar
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
endp getChar

proc readValue

endp readValue

; address of the string in es:di, uses cx, returns the zero flag
proc cmpCurrentID
	cld
	mov cx, MAX_ID_LEN
	mov si, offset current_id
	; I don't want to use repE because I need to terminate on \n (there may be unequal garbage beyond it)
	myRepE:
		; apparently it's possible to use cmps [byte ptr ds:si], [byte ptr es:di], in case I need customization
		cmpsb
		jne endCmpCurrentID
		cmp [byte ptr ds:si - 1], LF
		je endCmpCurrentID
	loop myRepE
	endCmpCurrentID: ret
endp cmpCurrentID

end main