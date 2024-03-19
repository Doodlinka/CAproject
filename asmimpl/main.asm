ideal
p286
p287
model compact

MAX_DATA_AMOUNT equ 10000
MAX_ID_LEN equ 16
CR equ 10
LF equ 13
ASCII_ZERO equ 48

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
DataSeg
	bxFor3F dw 0
	cxFor3F dw 1

UDataSeg
	current_id db MAX_ID_LEN dup(?)
	input_char db ?

Stack 256

; it says "location counter overlow", but this is exactly 64KB, and it looks fine on the map
segment ValueSegment
	values DataPoint 8192 dup(<>)
ends ValueSegment

segment ValueSegment2
	values2 DataPoint MAX_DATA_AMOUNT - 8192 dup(<>)
ends ValueSegment2

; I can't use the number 65536, I have to define separate names or use a bigger type instead
segment IDSegment
	ids db 65535 dup(?)
	last_id_byte db ?
ends IDSegment

segment IDSegment2
	ids2 db 65535 dup(?)
	last_id_byte2 db ?
ends IDSegment2

segment IDSegment3
	ids3 db (MAX_DATA_AMOUNT - 8192) * 16 dup(?)
ends IDSegment3


CodeSeg
proc main
	mov ax, @data
	mov ds, ax

	mov dx, offset input_char
	mov bx, 0
	mov cx, MAX_ID_LEN
	readLoop:
		call getChar
		jz doneReading
		; put the char into the buffer
		mov al, [input_char]
		mov [current_id + bx], al
		; move on to the next iteration
		inc bx
	loop readLoop
	doneReading:

	mov ax, 4c00h
    int 21h
endp main

; may not flexible enough with the register use
; takes the buffer in dx
; TODO: consider pushing/popping bx and cx instead
proc getChar
	; https://www.stanislavs.org/helppc/int_21-3f.html
	mov ah, 3Fh
	xchg bx, [bxFor3F]
	xchg cx, [cxFor3F]
	int 21h
	; restore our values
	xchg bx, [bxFor3F]
	xchg cx, [cxFor3F]
	; check for EOF
	test ax, ax
	ret
endp getChar

; uses all general regs, returns ax, assumes the file pointer is at the value stage
proc readValue
	xor ax, ax
	mov dx, offset input_char
	; cx will be 0 if we read a '-'
	call getChar
	mov cx, [input_char]
	sub cx, '-'
	jnz dontConsumeValueChar
	readValueLoop:
		; get a char, return if EOF
		push ax
		call getChar
		pop ax
		jz endGetValue
		dontConsumeValueChar:
		; return if EOL
		mov bx, [input_char]
		cmp bx, CR
		je endGetValue
		cmp bx, LF
		je endGetValue
		; append digit to the result (would lea be better?)
		mul 10
		add ax, bx
		sub ax, ASCII_ZERO
	jne readValueLoop
	; account for the '-'
	test cx, cx
	jnz endGetValue
	neg ax
	endGetValue: ret
endp readValue

; address of the string in es:di, uses cx and si, returns the zero flag
proc cmpCurrentIDToEsDi
	cld
	mov cx, MAX_ID_LEN
	mov si, offset current_id
	assume ds:@data
	; I don't want to use repE because I need to terminate on \n (there may be unequal garbage beyond it)
	myRepE:
		; it's possible to use cmps [byte ptr ds:si], [byte ptr es:di], in case I need customization
		cmpsb
		jne endCmpCurrentID
		cmp [byte ptr ds:si - 1], LF
	loopne myRepE
	endCmpCurrentID: ret
endp cmpCurrentIDToEsDi

end main