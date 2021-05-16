.386
.model flat, stdcall
option casemap: none
.data

.code
start:
ReadFileInput proc
	push ebp
	mov ebp, esp
	push 4 					;FILE_ATTRIBUTE_SYSTEM
	push 3					;OPEN_EXISTING
	push 1					;FILE_SHARE_READ
	ret

ReadFileInput endp

end start