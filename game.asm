INCLUDE Irvine32.inc

.data
	grid BYTE 42 DUP('.')
	promptMessage BYTE "Enter a column 1 to 7: ", 0
	rowString BYTE "| . . . . . . . |", 0 
.code
main PROC
	mov ecx, 6
printRows:
	mov edx, OFFSET rowString
	call WriteString
	call Crlf
	loop printRows

	exit
main ENDP
END main