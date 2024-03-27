ideal
p286
model compact

MAX_DATA_AMOUNT equ 10000
MAX_ID_LEN equ 16
CR equ 10
LF equ 13
ASCII_ZERO equ 48

struc DataPoint
	sum_or_average dd ? ; low word, high word
	count dw ?
	id_index dw ?
ends DataPoint

; TODO: I'll have to define two or three extra segments to store the worst-case memory requirement
; model compact may be crucial because it allows several data segments, but apparently it's possible to not go by a model entirely?
; each segment can fit 4096 IDs, 8192 values, or 2978 full structs
; refer to pages 21-22 and 447-461 of *the book* for details 
; https://archive.org/details/bitsavers_borlandtureringTurboAssembler2ed1995_80572557/page/446/mode/2up?view=theater
DataSeg
	bx_for_3F dw 0
	cx_for_3F dw 1
	data_length dw 0

UDataSeg
	current_id db MAX_ID_LEN dup(?)
	input_char db ?

Stack 256

; it says "location counter overlow", but this is exactly 64KB, and it looks fine on the map
segment ValueSegment
	values DataPoint 8192 dup(<>)
ends ValueSegment

segment ValueSegment2
	values_2 DataPoint MAX_DATA_AMOUNT - 8192 dup(<>)
ends ValueSegment2

; I can't use the number 65536, I have to define separate names or use a bigger type instead
segment IDSegment
	ids db 65535 dup(?)
	db ?
ends IDSegment

segment IDSegment2
	ids_2 db 65535 dup(?)
	db ?
ends IDSegment2

segment IDSegment3
	ids_3 db (MAX_DATA_AMOUNT - 8192) * 16 dup(?)
ends IDSegment3


CodeSeg
proc main
	mov ax, @data
	mov ds, ax

	readLoop:
		mov dx, offset input_char
		mov cx, MAX_ID_LEN
		xor bx, bx
		readIDLoop:
			call getChar
			jz doneReading
			; consume second newline if present
			cmp al, LF
			je readLoop
			mov [current_id + bx], al
			inc bx
			cmp al, ' '
			je readValueStage
		loop readIDLoop
		call getChar ; if the loop exited normally, we read 16 chars and need to consume the ' '
		readValueStage:
		call readValue
		
		mov ax, IDSegment
		mov es, ax
		xor di, di
		mov cx, [data_length]
		test cx, cx
		jz saveNewID
		call findCurrentID
		je haveFoundID

		saveNewID:
		; if the ID wasn't found, save it and zero its values
		call saveCurrentIDToEsDi
		xor dl, dl ; remember that ID wasn't found, works as long as offset input_char's low byte isn't naturally zero

		haveFoundID:
		; figure out the address of the value
		neg cx
		add cx, [data_length]
		mov di, cx
		cmp di, 8192
		mov ax, ValueSegment
		jb noValueSegOverlow
		mov ax, ValueSegment2
		noValueSegOverlow:
		mov es, ax
		shl di, 3
		; this mube done if the ID hasn't been found, but only after di is calculated
		test dl, dl
		jnz skipZeroingValues
		mov [word ptr es:di], 0 ; low sum
		mov [word ptr es:di + 2], 0 ; high sum
		mov [word ptr es:di + 4], 0 ; count
		mov [word ptr es:di + 6], 0 ; string index
		inc [data_length]

		skipZeroingValues:
		add [word ptr es:di], bx ; low sum
		adc [word ptr es:di + 2], 0 ; high sum
		inc [word ptr es:di + 4] ; count
		mov [word ptr es:di + 6], cx ; string index
	jmp readLoop
	doneReading:

	mov ax, 4c00h
    int 21h
endp main

; may not flexible enough with the register use
; takes the buffer in dx, returns al
; TODO: consider pushing/popping bx and cx instead
proc getChar
	; https://www.stanislavs.org/helppc/int_21-3f.html
	mov ah, 3Fh
	xchg bx, [bx_for_3F]
	xchg cx, [cx_for_3F]
	int 21h
	; restore our values
	xchg bx, [bx_for_3F]
	xchg cx, [cx_for_3F]
	; check for EOF
	test ax, ax
	mov al, [input_char]
	ret
endp getChar

; uses all general regs, returns bx, assumes the stdin pointer is at the value stage
; TODO: consider using pushf and popf instead of cl (and make getChar not save cx by default?)
proc readValue
	xor bx, bx
	; cl will be 0 if a '-' is read
	call getChar
	mov cl, al
	sub cl, '-'
	jnz dontConsumeValueChar
	readValueLoop:
		; get a char, stop reading if EOF
		call getChar
		jz stopReadingValue
		dontConsumeValueChar:
		; stop reading if EOL
		cmp al, CR
		je stopReadingValue
		cmp al, LF
		je stopReadingValue
		; append digit to the result (I'd use lea into ax if it didn't suck pre-386)
		imul bx, 10
		add bx, ax ; ah gotta be zero after a 3FH call
		sub bx, ASCII_ZERO
	jmp readValueLoop
	; account for the '-'
	stopReadingValue:
	test cl, cl
	jnz retGetValue
	neg bx
	retGetValue: ret
endp readValue

; sets zf if it has been found, returns the reverse index in cx
proc findCurrentID
	findIDLoop:
		call cmpCurrentIDToEsDi
		je retFindCurrentID
		dec ax ; if they weren't equal, ax didn't get decreased one last time
		add di, ax
		jno noIDSegOverflow
		mov dx, es
		add dx, 4096
		mov es, dx
		noIDSegOverflow:
	loop findIDLoop
	retFindCurrentID: ret
endp findCurrentID

; address of the string in es:di, uses si, returns the zero flag (and cx if zf=0), assumes ds = @data
proc cmpCurrentIDToEsDi
	cld
	mov ax, MAX_ID_LEN
	mov si, offset current_id
	myRepE: ; I can't use actual repE because I need to terminate on ' ' (there will be unequal garbage beyond)
		cmpsb ; it's possible to use cmps [byte ptr ds:si], [byte ptr es:di], in case I need customization
		jne retCmpCurrentID ; if this jump happens, ax won't get decreased one last time, will have to adjust outside to not mess the flags up
		cmp [byte ptr ds:si - 1], ' '
		je retCmpCurrentID ; this avois decrementing ax too, but I don't need it when a match is found
		dec ax
	jnz myRepE
	retCmpCurrentID: ret
endp cmpCurrentIDToEsDi

proc saveCurrentIDToEsDi
	mov si, offset current_id
	mov cx, MAX_ID_LEN
	saveCurrentIDLoop:
		movsb
		cmp [byte ptr ds:si - 1], ' '
	loopne saveCurrentIDLoop
	ret
endp saveCurrentIDToEsDi

end main