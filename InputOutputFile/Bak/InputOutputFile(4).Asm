.386
.model flat, stdcall
option casemap: none
include windows.inc
include user32.inc
include kernel32.inc

includelib user32.lib
includelib kernel32.lib

.data
	szErrorCaption	db "Error!",0				;Caption thong bao loi
	szErrorText		db "Cannot OpenFile", 0		;doan thong bao loi
	inputString db 100 dup(0)
	OutputString db 100 dup(0)
	CaptionKq db "Thong bao ket qua", 0
	pathInput db "Input.txt", 0
	pathOutput db "Output.txt", 0
.code
start:
	push offset inputString
	push offset pathInput
	call ReadFileInput
	
	push offset inputString
	push offset pathOutput
	call WriteFileOutput
	
	push MB_OK
	push offset CaptionKq
	push offset inputString
	push 0
	call MessageBox
	
	push 0
	call ExitProcess
ReadFileInput proc
	;LOCAL FileSizeHigh:dword	[ebp - 4]
	;LOCAL FileSize:dword		[ebp - 8]		; Bien cuc bo chua kich thuoc file
	;LOCAL hHandleFileInput:dword 	[ebp - 12]	; Bien cuc bo kieu dword
	;LOCAL nByteRead:dword		[ebp - 16]
	
	push ebp
	mov ebp, esp
	add esp, -10h
	mov eax, [ebp + 8]			; eax tro toi dia chi string "Input.txt"
	push 0h 					;hTemplateFile = NULL
	push 4h 					;FILE_ATTRIBUTE_SYSTEM
	push 3h						;OPEN_EXISTING
	push 0h						;pSercurity = NULL
	push 1h						;FILE_SHARE_READ
	push GENERIC_READ				;GENERIC_READ
	push eax
	call CreateFile				; ket qua tra ve eax, chua dia chi offset file

	mov  [ebp - 4], eax				;dua gia tri eax vao bien cuc bo hHandleFileInput
	cmp  eax, INVALID_HANDLE_VALUE			;kiem tra eax voi gia tri khong hop le
	je	 errReadFileText				; nhay den ham thong bao loi neu bang
	
	lea  eax, [ebp - 8]				; load dia chi bien FileZiseHigh vao eax
	push eax						; push filesizehigh
	push [ebp - 4]					;push handle file input
	call GetFileSize 				; kich thuoc file tra ve eax
	mov  [ebp - 8], eax				; dua eax vao stack [ebp - 8]
	
	push 0
	lea  eax, [ebp - 16]
	push eax
	push [ebp - 8]
	
	mov eax, [ebp + 12]
	push eax
	push [ebp - 4]
	Call ReadFile 
	
	push [ebp - 4]
	call CloseHandle
	
	leave
	ret 8
errReadFileText:
	push offset szErrorCaption
	push offset szErrorText			;push thong bao loi vao
	call ErrorMessage 				; goi ham in ra thong bao loi 

ReadFileInput endp

WriteFileOutput proc
;LOCAL hHandleFileInput:dword 	[ebp - 4]	; Bien cuc bo kieu dword
;LOCAL BufferLength : dword  [ebp - 8]
;LOCAL nByteWrite:dword     [ebp - 12]
	push ebp 
	mov ebp, esp
	pushad
	add esp, -12h
	
	mov eax, [ebp + 8]
	push 0
	push 0
	push 3h
	push 0
	push 1h
	push GENERIC_WRITE
	push eax
	Call CreateFile
	
	mov  [ebp - 4], eax
	cmp  eax, INVALID_HANDLE_VALUE
	je	 _errWriteFileText

	
	push FILE_END
	push 0
	push 0
	push [ebp - 4]
	call SetFilePointer
	
	push [ebp + 12]
	call lstrlen
	mov  [ebp - 8], eax
	
	push 0
	lea  eax, [ebp - 12]
	push eax
	push [ebp - 8]
	push [ebp + 12]
	push [ebp - 4]
	Call WriteFile 
	
	push [ebp - 4]
	call CloseHandle
	popad
	leave
	ret 8
_errWriteFileText:
	push offset szErrorCaption
	push offset szErrorText			;push thong bao loi vao
	call ErrorMessage 				; goi ham in ra thong bao loi 
	
WriteFileOutput endp
ErrorMessage proc
	push ebp
	mov ebp, esp
	push MB_OK
	mov eax, [ebp + 12]
	push eax
	mov ebx, [ebp + 8]
	push ebx
	push 0
	call MessageBox
	leave
	ret 8

ErrorMessage endp
end start