INCLUDE Irvine32.inc

; Test on commiting code to the repo

.data
	msg BYTE "Hello Alejandro!", 0
	string DWORD 0

.code
	main PROC
	mov edx, OFFSET msg
	mov eax, edx
	call WriteString
	call ReadChar
	exit

main ENDP

END main
