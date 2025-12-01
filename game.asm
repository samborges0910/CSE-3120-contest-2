INCLUDE Irvine32.inc

.data
	grid BYTE 42 DUP('.')
	promptMessage BYTE "Enter a column 1 to 7, or 0 to quit: ", 0
	invalidMessage BYTE "Invalid input. Try again.", 0
	rowString BYTE "| . . . . . . . |", 0

	turn BYTE 0 ; tracks whos turn it is, X or O

.code

;--- Printing grid ---
printGrid PROC ; function for printing the grid
	mov esi, OFFSET grid
	mov ecx, 6

printRow: ; added loops to print rows and columns
	mov edi, OFFSET rowString
	add edi, 2
	mov edx, 7

printColumn:
	mov al, [esi]
	mov [edi], al
	add edi, 2
	inc esi
	dec edx
	jnz printColumn
	mov edx, OFFSET rowString
	call WriteString
	call Crlf
	loop printRow
	ret

printGrid ENDP

;--- Dropping disc function ---
dropDisc PROC
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
