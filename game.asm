INCLUDE Irvine32.inc

.data
	grid BYTE 42 DUP('.')
	promptMessage BYTE "Enter a column 1 to 7, or 0 to quit: ", 0
	invalidMessage BYTE "Invalid input. Try again.", 0
	rowString BYTE "| . . . . . . . |", 0
	fullColumnMessage BYTE "Column is full. Try another column.", 0
	xWinMessage BYTE "Player X wins!", 0
	oWinMessage BYTE "Player O wins!", 0
	turn BYTE 0 ; tracks whos turn it is, X or O

.code

;--- Printing grid ---
printGrid PROC
mov esi, OFFSET grid; pointer to grid(6×7)
mov ecx, 6; logical row counter

printRow :
push ecx; save logical row counter
mov edi, 2; print each row twice(2 - high)

rowHeightLoop:

; ----Center row----
mov eax, 15
call SetTextColor
mov ebx, 32
centerLoop:
mov al, ' '
call WriteChar
dec ebx
jnz centerLoop

; ----Left border----
mov eax, 15
call SetTextColor
mov al, '|'
call WriteChar

; ----Print columns----
mov edx, esi; EDX = temp pointer for columns
mov ebx, 7; 7 columns

printColumn :
mov al, [edx]; read grid cell

cmp al, '.'
je emptyCell
cmp al, 'X'
je xCell
cmp al, 'O'
je oCell

emptyCell :
mov eax, 7; light gray
call SetTextColor
mov al, 219; ?
call WriteChar
call WriteChar; 2 - wide
mov al, ' '
call WriteChar; horizontal spacing
jmp nextCell

xCell :
mov eax, 12; bright red
call SetTextColor
mov al, 219
call WriteChar
call WriteChar
mov al, ' '
call WriteChar
jmp nextCell

oCell :
mov eax, 11; bright cyan
call SetTextColor
mov al, 219
call WriteChar
call WriteChar
mov al, ' '
call WriteChar

nextCell :
inc edx
dec ebx
jnz printColumn

; ----Right border----
mov eax, 15
call SetTextColor
mov al, '|'
call WriteChar

call Crlf

dec edi
jnz rowHeightLoop

; ----------VERTICAL SPACING BETWEEN ROWS----------
; print one blank centered line
mov eax, 15
call SetTextColor

mov ebx, 32
space2Loop:
mov al, ' '
call WriteChar
dec ebx
jnz space2Loop

call Crlf

; ----------NEXT LOGICAL ROW----------
pop ecx
add esi, 7; next grid row
dec ecx
jnz printRow

ret
printGrid ENDP

;--- Dropping disc function ---
dropDisc PROC
	mov ecx, 6 ; fix full column bug
	dec eax
	mov ebx, eax
	mov edx, 5 ; disc will be inserted at the bottom of the grid

chosenSpot: ; inserting disc at desired column
	mov esi, OFFSET grid ; pointer to start of grid
	mov eax, edx
	imul eax, 7 ; multiply row index by number of columns
	add eax, ebx
	add esi, eax ; point to grid[row][col]
	cmp BYTE PTR [esi], '.'
	je placeX
	dec edx
	loop chosenSpot
	mov eax, 0
	ret

placeX: ; added player X
	cmp turn, 0
	je placeO ; if turn = 0, jump to player O
	mov BYTE PTR [esi], 'X'
	jmp switchTurn

placeO:
mov BYTE PTR[esi], 'O'

switchTurn : ; function to switch turns between player O and X
xor turn, 1
mov eax, 1
ret

dropDisc ENDP

checkBoundries PROC ; checks if esi is within the bounds of the grid returns 1 if it is else 0 in eax
	push edx
	push ecx

	mov edx, offset grid
	mov ecx, edx
	add ecx, 42

	cmp esi, edx
	jb out_of_bounds

	cmp esi, ecx
	jae out_of_bounds

	jmp in_bounds

	out_of_bounds:
	mov eax, 0
	jmp done

	in_bounds:
	mov eax, 1

	done:
	pop ecx
	pop edx
	ret
checkBoundries ENDP

checkWin PROC
	push ebx
	push ecx
	push edx
	push esi
	push edi

	; Check horizontal wins(4 in a row)
	mov edi, 0; row counter

	checkHorizRow :
	cmp edi, 6
	jge checkVertStart; done with all rows

	mov esi, OFFSET grid
	mov eax, edi
	imul eax, 7; row offset
	add esi, eax

	mov ebx, 0; column counter

	checkHorizCol :
	cmp ebx, 4; can only check columns 0 - 3
	jge nextHorizRow

	mov al, [esi + ebx]; first piece
	cmp al, '.'
	je incHorizCol

	; Check if next 3 match
	mov dl, [esi + ebx + 1]
	cmp al, dl
	jne incHorizCol
	mov dl, [esi + ebx + 2]
	cmp al, dl
	jne incHorizCol
	mov dl, [esi + ebx + 3]
	cmp al, dl
	jne incHorizCol

	; Found winner
	jmp foundWinner

	incHorizCol :
	inc ebx
	jmp checkHorizCol

	nextHorizRow :
	inc edi
	jmp checkHorizRow

	; Check vertical wins
	checkVertStart :
	mov edi, 0; row counter

	checkVertRow :
	cmp edi, 3; can only check rows 0 - 2
	jge checkDiagUpStart

	mov ebx, 0; column counter

	checkVertCol :
	cmp ebx, 7
	jge nextVertRow

	mov esi, OFFSET grid
	mov eax, edi
	imul eax, 7
	add eax, ebx
	add esi, eax

	mov al, [esi]; first piece
	cmp al, '.'
	je incVertCol

	; Check next 3 down
	mov dl, [esi + 7]
	cmp al, dl
	jne incVertCol
	mov dl, [esi + 14]
	cmp al, dl
	jne incVertCol
	mov dl, [esi + 21]
	cmp al, dl
	jne incVertCol

	; Found winner
	jmp foundWinner

	incVertCol :
	inc ebx
	jmp checkVertCol

	nextVertRow :
	inc edi
	jmp checkVertRow

	; Check diagonal / (up - right)
	checkDiagUpStart:
	mov edi, 3; start at row 3

	checkDiagUpRow:
	cmp edi, 6
	jge checkDiagDownStart

	mov ebx, 0; column counter

	checkDiagUpCol :
	cmp ebx, 4; can only check columns 0 - 3
	jge nextDiagUpRow

	mov esi, OFFSET grid
	mov eax, edi
	imul eax, 7
	add eax, ebx
	add esi, eax

	mov al, [esi]
	cmp al, '.'
	je incDiagUpCol

	; Check diagonal up - right
	mov dl, [esi - 6]; row - 1, col + 1
	cmp al, dl
	jne incDiagUpCol
	mov dl, [esi - 12]
	cmp al, dl
	jne incDiagUpCol
	mov dl, [esi - 18]
	cmp al, dl
	jne incDiagUpCol

	; Found winner
	jmp foundWinner

	incDiagUpCol :
	inc ebx
	jmp checkDiagUpCol

	nextDiagUpRow :
	inc edi
	jmp checkDiagUpRow

	; Check diagonal \ (down - right)
	checkDiagDownStart:
	mov edi, 0; start at row 0

	checkDiagDownRow:
	cmp edi, 3; can only check rows 0 - 2
	jge noWinner

	mov ebx, 0; column counter

	checkDiagDownCol :
	cmp ebx, 4; can only check columns 0 - 3
	jge nextDiagDownRow

	mov esi, OFFSET grid
	mov eax, edi
	imul eax, 7
	add eax, ebx
	add esi, eax

	mov al, [esi]
	cmp al, '.'
	je incDiagDownCol

	; Check diagonal down - right
	mov dl, [esi + 8]; row + 1, col + 1
	cmp al, dl
	jne incDiagDownCol
	mov dl, [esi + 16]
	cmp al, dl
	jne incDiagDownCol
	mov dl, [esi + 24]
	cmp al, dl
	jne incDiagDownCol

	; Found winner
	jmp foundWinner

	incDiagDownCol :
	inc ebx
	jmp checkDiagDownCol

	nextDiagDownRow :
	inc edi
	jmp checkDiagDownRow

	noWinner :
	mov al, '.'
	jmp checkWinDone

	foundWinner :
	; al already contains winning character

	checkWinDone :
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	ret
checkWin ENDP

;--- Main ---
main PROC

mainLoop: ; implement main loop to prompt input
	call printGrid
	call Crlf
	mov edx, OFFSET promptMessage ; asks for user input
	call WriteString
	call ReadInt
	cmp eax, 0 ; if input 0, terminate program
	je quitProgram
	jl invalid
	cmp eax, 7
	jg invalid
	cmp eax, 1
	push eax
	call dropDisc
	cmp eax, 1
	jne columnFull
	call checkWin
	cmp al, '.'
	jne won

	jmp mainLoop

columnFull: ; outputs message if the column is full and cannot accept any more discs
	mov edx, OFFSET fullColumnMessage
	call WriteString
	call Crlf
	jmp mainLoop

invalid:
	mov edx, OFFSET invalidMessage
	call WriteString
	call Crlf
	jmp mainLoop

won:
	call printGrid

quitProgram:
	exit

	exit
main ENDP

END main
