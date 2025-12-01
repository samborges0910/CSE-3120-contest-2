INCLUDE Irvine32.inc

.data
	grid BYTE 42 DUP('.')
	promptMessage BYTE "Enter a column 1 to 7: ", 0
	rowString BYTE "| . . . . . . . |", 0 
.code

printGrid PROC ; function for printing the grid
	mov ecx, 6	; amount of rows
	mov ebx, 0	; index counter

printGrid ENDP

main PROC
	mov ecx, 6
printRows:
	mov edx, OFFSET rowString
	call WriteString
	call Crlf
	loop printRows

mainLoop: ; implement main loop to prompt input
	mov edx, OFFSET promptMessage
	call WriteString
	call ReadInt
	jmp mainLoop

	exit
main ENDP
END main