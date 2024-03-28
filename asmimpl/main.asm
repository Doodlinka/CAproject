ideal
p286
model compact

MAX_DATA_AMOUNT equ 10000
MAX_ID_LEN equ 16
CR equ 10
LF equ 13
ASCII_ZERO equ 48

; didn't figure out how to index by name, so this is just documentation
; TODO: string indexes are known before sorting, so only store sum and count at the start
; then, save the string indexes when dividing
struc DataPoint 
	low_sum_or_average dw ?
	high_sum dw ?
	count dw ?
	id_index dw ?
ends DataPoint

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

; I can't use the number 65536
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

	call readValues
	call computeAverages
	
	; TODO: put in procedure, check if no swaps happened
	mov cx, [data_length]
	dec cx
	mov ax, ValueSegment
	mov es, ax
	outerSortLoop:
		push cx
		xor bx, bx
		innerSortLoop:
			mov ax, [es:bx]
			cmp ax, [es:bx + 8] ; averages
			jge dontSwap ; descending (swap if left < right)
			xchg [es:bx + 8], ax ; swap average
			mov [es:bx], ax
			mov ax, [es:bx + 6] ; swap string index
			xchg [es:bx + 8 + 6], ax
			mov [es:bx + 6], ax
			dontSwap:
			add bx, 8 ; TODO: overflow check or decrease structure size to 6 bytes
		loop innerSortLoop
		pop cx
	loop outerSortLoop

	mov cx, [data_length]
	mov ax, ValueSegment
	mov es, ax
	mov bx, 6
	outerPrintLoop:
		mov ax, IDSegment
		add ax, [es:bx] ; this only works because IDs are 16 wide, beginning can be addressed with just the segment
		mov ds, ax
		xor si, si
		push cx
		mov cx, MAX_ID_LEN
		innerPrintLoop:
			lodsb
			cmp al, ' '
			je breakInnerPrintLoop
			mov dl, al
			mov ah, 02h
			int 21h
		loop innerPrintLoop
		breakInnerPrintLoop:
		pop cx
		mov dl, LF
		int 21h
		add bx, 8
	loop outerPrintLoop

	mov ax, 4c00h
    int 21h
endp main


proc computeAverages ; TODO: do the 8192 check only once at beginning, then repeat if necessary
	mov cx, [data_length]
	xor bx, bx
	mov ax, ValueSegment
	mov es, ax
	divLoop:
		mov ax, [es:bx] ; low sum
		mov dx, [es:bx + 2] ; high sum
		idiv [word ptr es:bx + 4] ; count
		mov [es:bx], ax
		add bx, 8
		jnc noValueSegOverflowWhenDividing
		mov ax, es
		add ax, 4096
		mov es, ax
		noValueSegOverflowWhenDividing:
	loop divLoop
	ret
endp computeAverages


proc readValues
	readLoop:
		mov dx, offset input_char
		mov cx, MAX_ID_LEN
		xor bx, bx
		readIDLoop:
			call getChar
			jz retReadValues
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
		call readValue ; TODO: move this past the id search, maybe? cuz I have to keep bx the entire time
		
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
		add cx, [data_length] ; now it contains the index
		mov di, cx
		cmp di, 8192
		mov ax, ValueSegment
		jb noValueSegOverflowWhenSaving
		mov ax, ValueSegment2
		noValueSegOverflowWhenSaving:
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
		mov ax, bx ; guess I should've read it into ax, but don't care
		cwd ; gotta make sure that negatives ahve infinite -1s to the left or shit won't be subtracting
		add [word ptr es:di], ax ; low sum
		adc [word ptr es:di + 2], dx ; high sum
		inc [word ptr es:di + 4] ; count
		mov [word ptr es:di + 6], cx ; string index
	jmp readLoop

	retReadValues: ret
endp readValues

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
		jnc noIDSegOverflowWhenSearching
		mov dx, es
		add dx, 4096
		mov es, dx
		noIDSegOverflowWhenSearching:
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
	push cx
	mov si, offset current_id
	mov cx, MAX_ID_LEN
	saveCurrentIDLoop:
		movsb
		cmp [byte ptr ds:si - 1], ' '
	loopne saveCurrentIDLoop
	pop cx
	ret
endp saveCurrentIDToEsDi

end main