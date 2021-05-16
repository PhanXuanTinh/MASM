.386
.model flat, stdcall
option casemap: none
include windows.inc
include user32.inc
include kernel32.inc

includelib user32.lib
includelib kernel32.lib

.data
	fileInput db "Input.txt"
.code
start:
	push fileInput
	call ReadFileInput
ReadFileInput proc
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8]			; eax tro toi dia chi string "Input.txt"
	push 0h 					;hTemplateFile = NULL
	push 4h 					;FILE_ATTRIBUTE_SYSTEM
	push 3h						;OPEN_EXISTING
	push 0h						;pSercurity = NULL
	push 1h						;FILE_SHARE_READ
	push 80000000h				;GENERIC_READ
	ret

ReadFileInput endp

end start