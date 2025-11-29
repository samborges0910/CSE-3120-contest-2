INCLUDE Irvine32.inc

.data
	rowString BYTE "|. . . . . . .|", 0     ; constructing the 6x7 grid
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
