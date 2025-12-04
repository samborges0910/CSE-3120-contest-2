INCLUDE Irvine32.inc

.data
	grid BYTE 42 DUP('.')
	promptMessage BYTE "Enter a column 1 to 7, or 0 to quit: ", 0
	invalidMessage BYTE "Invalid input. Try again.", 0
	rowString BYTE "| . . . . . . . |", 0
	fullColumnMessage BYTE "Column is full. Try another column.", 0

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
	mov BYTE PTR [esi], 'O'

switchTurn: ; function to switch turns between player O and X
	xor turn, 1
	mov eax, 1
	ret

dropDisc ENDP

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

quitProgram:
	exit

	exit
main ENDP

END main
