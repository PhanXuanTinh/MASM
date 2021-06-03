.386
.model flat, stdcall
.stack 100h

include windows.inc
include user32.inc
include kernel32.inc

includelib user32.lib
includelib kernel32.lib

.data
	szErrorCaption	db "Error!",0				;Caption thong bao loi
	szErrorText		db "Cannot OpenFile", 0		;doan thong bao loi
	szInputPath db "notepad.txt",0 				;duong dan file input
	szOutputPath db "Output.txt",0  			;duong dan file output
	szOutputString	db 100 dup (0)				;chuoi de in ra file output
	szInputString	db 100 dup (0)				;chuoi de doc tu file input
	
	entryPointStr db "entryPoint: ",0

.code
start:
	push offset szInputString
	push offset szInputPath
	call ReadFileInput
	
	push 0
	call ExitProcess

HexToAscii proc
	;prameter eax,string
	push ebp
	mov ebp, esp
	
	ret

HexToAscii endp
ReadFileInput proc
	; tham so: szInputString, szInputPath
	;LOCAL hHandleFileInput:dword 	[ebp - 4]	; Bien cuc bo kieu dword
	;LOCAL FileSizeHigh:dword	[ebp - 8]
	;LOCAL FileSize:dword		[ebp - 12]		; Bien cuc bo chua kich thuoc file	
	;LOCAL nByteRead:dword		[ebp - 16]
	
	push ebp
	mov ebp, esp
	add esp, -10h				;dwCurrentFilePosition [ebp - 20]
	mov eax, [ebp + 8]			
	push NULL					;hTemplateFile = NULL
	push FILE_ATTRIBUTE_SYSTEM 				
	push OPEN_EXISTING				;open file exit
	push NULL						;pSercurity = NULL
	push FILE_SHARE_READ					;FILE_SHARE_READ
	push GENERIC_READ			;GENERIC_READ
	push eax
	call CreateFile				; ket qua tra ve eax, chua dia chi offset file
	
	
	mov  [ebp - 4], eax				;dua gia tri eax vao bien cuc bo hHandleFileInput
	cmp  eax, -1			;kiem tra eax voi gia tri khong hop le
	je	 errReadFileText				; nhay den ham thong bao loi neu bang
	
	push FILE_CURRENT
	push NULL
	push 4
	push [ebp -4]						;HANDLE
	call SetFilePointer
	
	push 0
	lea  eax, [ebp - 16]			;byteread
	push eax
	push 4							;Doc 4 byte
	;mov eax, [ebp + 12]				;InputString
	push eax
	push [ebp - 4]					;push handle file input
	Call ReadFile 
	
	push [ebp - 4]					;;push handle file input
	call CloseHandle
	
	leave
	ret 8
errReadFileText:
	push offset szErrorCaption
	push offset szErrorText			;push thong bao loi vao
	call ErrorMessage 				; goi ham in ra thong bao loi 
	ret

ReadFileInput endp

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