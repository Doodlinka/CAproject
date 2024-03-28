ideal
p286
model compact

MAX_DATA_AMOUNT equ 10000
MAX_ID_LEN equ 16
CR equ 13
LF equ 10
ASCII_ZERO equ 48
DATA_WIDTH equ 6
ID_INDEX_OFFSET equ 2

; didn't figure out how to index by name, so this is just documentation
struc DataPoint 
	low_sum_OR_average dw ?
	high_sum_OR_id_index dw ?
	count_OR_obsolete dw ?
ends DataPoint

DataSeg
	bx_for_3F dw 0
	cx_for_3F dw 1
	data_length dw 0

UDataSeg
	current_id db MAX_ID_LEN dup(?)
	input_char db ?

Stack 256

segment ValueSegment
	values DataPoint MAX_DATA_AMOUNT dup(<>)
ends ValueSegment

segment AuxValueSegment
	values DataPoint MAX_DATA_AMOUNT dup(<>)
ends AuxValueSegment

; it says "location counter overlow", but this is exactly 64KB, and it looks fine on the map
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
	call bubbleSort
	call printResults

	mov ax, 4c00h
    int 21h
endp main

proc printResults
	mov cx, [data_length]
	mov ax, ValueSegment
	mov es, ax
	mov bx, ID_INDEX_OFFSET
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
		mov dl, CR
		int 21h
		mov dl, LF
		int 21h
		add bx, DATA_WIDTH
	loop outerPrintLoop
	ret
endp printResults


proc mergeSort
	mov ax, ValueSegment
	mov ds, ax
	mov ax, AuxValueSegment
	mov es, ax
	mov bx, DATA_WIDTH ; merge width

	mergeSortLoop:
		xor si, si
		xor di, di
		mov cx, [data_length]
		cld
		copyToAuxLoop: ; assumes DATA_WIDTH == 6
			lodsw
			stosw
			lodsw
			stosw
			lodsw
			stosw
		loop copyToAuxLoop

		mov cx, [data_length]
		xor si, si ; area 1 index
		mov di, bx ; area 2 index
		push bx
		xor bx, bx ; result index
		mov ax, DATA_WIDTH
		mergeBackLoop:
			; if one of the indices is at the end of its range, use the other
			cmp si, ax
			ja takeSecond
			add ax, DATA_WIDTH
			cmp di, ax
			pushf
			sub ax, DATA_WIDTH
			popf
			ja takeFirst
			
			mov dx, [es:si]
			cmp dx, [es:di]
			jge takeFirst
			takeSecond:
				mov dx, [es:di]
				mov [ds:bx], dx
				mov dx, [es:di + ID_INDEX_OFFSET]
				add di, DATA_WIDTH
				jmp endMergeIf
			takeFirst:
				; mov dx, [es:si]
				mov [ds:bx], dx
				mov dx, [es:si + ID_INDEX_OFFSET]
				mov [ds:bx + ID_INDEX_OFFSET], dx
				add si, DATA_WIDTH
			endMergeIf:
			
			add bx, DATA_WIDTH
		loop mergeBackLoop

		pop bx ; return the merge width
	jmp mergeSortLoop


	ret
endp mergeSort

proc bubbleSort
	mov cx, [data_length]
	dec cx
	mov ax, ValueSegment
	mov es, ax
	xor dl, dl ; set to 1 if no swaps happened
	outerBubbleSortLoop:
		push cx
		xor bx, bx
		inc dl
		innerBubbleSortLoop:
			mov ax, [es:bx]
			cmp ax, [es:bx + DATA_WIDTH] ; averages
			jge dontSwap ; descending (swap if left < right)
			xchg [es:bx + DATA_WIDTH], ax ; swap average
			mov [es:bx], ax
			mov ax, [es:bx + ID_INDEX_OFFSET] ; swap string index
			xchg [es:bx + DATA_WIDTH + ID_INDEX_OFFSET], ax
			mov [es:bx + ID_INDEX_OFFSET], ax
			xor dl, dl
			dontSwap:
			add bx, DATA_WIDTH
		loop innerBubbleSortLoop
		pop cx
		test dl, dl
		jnz retBubbleSort
	loop outerBubbleSortLoop
	retBubbleSort: ret
endp bubbleSort


proc computeAverages
	mov cx, [data_length]
	xor bx, bx
	mov ax, ValueSegment
	mov es, ax
	xor ax, ax
	divLoop:
		push ax
		mov ax, [es:bx] ; low sum
		mov dx, [es:bx + 2] ; high sum
		idiv [word ptr es:bx + 4] ; count
		mov [es:bx], ax
		pop ax
		mov [es:bx + ID_INDEX_OFFSET], ax
		inc ax
		add bx, DATA_WIDTH
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
		mov ax, ValueSegment
		mov es, ax
		mov ax, [data_length]
		sub ax, cx
		mov cx, DATA_WIDTH	
		mul cl
		mov di, ax
		; this mube done if the ID hasn't been found, but only after di is calculated
		test dl, dl
		jnz skipZeroingValues
		mov [word ptr es:di], 0 ; low sum
		mov [word ptr es:di + 2], 0 ; high sum
		mov [word ptr es:di + 4], 0 ; count
		inc [data_length]

		skipZeroingValues:
		mov ax, bx ; guess I should've read it into ax, but don't care
		cwd ; gotta make sure that negatives ahve infinite -1s to the left or shit won't be subtracting
		add [word ptr es:di], ax ; low sum
		adc [word ptr es:di + 2], dx ; high sum
		inc [word ptr es:di + 4] ; count
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