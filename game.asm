INCLUDE Irvine32.inc

.data
	grid BYTE 42 DUP('.')
	promptMessage BYTE "Enter a column 1 to 7: ", 0
	rowString BYTE "| . . . . . . . |", 0 

.code

;---printing grid---
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

; --- main ---
main PROC

mainLoop: ; implement main loop to prompt input
	call printGrid
	call Crlf
	mov edx, OFFSET promptMessage
	call WriteString
	call ReadInt
	jmp mainLoop

main ENDP

END main
