INCLUDE Irvine32.inc

.data
	grid BYTE 42 DUP('.')
	promptMessage BYTE "Enter a column 1 to 7, or 0 to quit: ", 0
	rowString BYTE "| . . . . . . . |", 0

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
	je placeO ; adds 'O' in empty spot
	dec edx
	cmp edx, -1
	jg chosenSpot ; now 'O' will be inserted at upper level
	ret

placeO:
	mov BYTE PTR [esi], 'O'
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
	cmp eax, 1
	push eax
	call dropDisc
	jmp mainLoop

quitProgram:
	exit

	exit
main ENDP

END main
