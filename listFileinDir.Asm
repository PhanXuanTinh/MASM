.386
.model flat, stdcall
.stack 100h
include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib


.data

	szErrorCaption	db "Error!",0				;Caption thong bao loi
	szErrorText		db "Cannot OpenFile", 0		;doan thong bao loi
	szInputPath db "in.txt",0 				;duong dan file input
	szOutputPath db "out.txt",0  			;duong dan file output
	szOutputString	db 100 dup (0)				;chuoi de in ra file output
	szInputString	db 100 dup (0)				;chuoi de doc tu file input
	
	applicationName db "C:\WINDOWS\system32\notepad.exe",0
	newLine db 0ah, 0
	cap db "Thong bao", 0
	mess1 db "Ban co muon show noi dung out.txt!!!", 0
	dot db ".", 0
	
	
	lpFindFile WIN32_FIND_DATA <>
	startUpInfo STARTUPINFO <>
	processInfo PROCESS_INFORMATION <>
	openBuff OFSTRUCT <>
.code
start:
	push offset szInputString
	push offset szInputPath
	call ReadFileInput
	
	push offset szInputString
	push offset lpFindFile
	call FindFile
	
	push MB_OKCANCEL
	push offset cap
	push offset mess1
	push 0
	call MessageBox
	
	cmp eax, 0
	je _exit
	
	push 1						;showcmd
	push 0						;lpDirectory
	push 0						;lpParametter
	push offset szOutputPath	;lpFile
	push 0						;lpOperation
	push 0						;hwnd
	call OpenAPP
	
_exit:	
	push 0
	call ExitProcess
	
FindFile proc
	;prameter : fileName, struct win32_find_data
	
	push ebp
	mov ebp, esp
	add esp, -4h							;local Hfile
	
	push [ebp + 8]							;lpFindFile
	push [ebp + 12]							;dirName
	call FindFirstFile
	mov [ebp - 4], eax						;Hfile = eax
	
	
	
	;------------GHI VAO FILE
	
	push offset lpFindFile.cFileName
	push offset szOutputPath
	call WriteFileOutput
	
	push offset newLine					; new line
	push offset szOutputPath				;out.txt
	call WriteFileOutput

	;----------KIEM TRA XEM LA FILE HAY FOLDER
	
	mov eax, lpFindFile.dwFileAttributes
	cmp eax, FILE_ATTRIBUTE_DIRECTORY							;the handle that identifies a directory
	jne _loop1								; neu k phai folder thi find next file
	
	;----------DOI DUONG DAN VA GOI LAI
	PUSH  [ebp + 12]
	call lstrlen							; eax bang do dai dirName
	
	lea edx, [ebp + 12]
	
	mov byte ptr [edx + eax], 5ch				; * thanh \
	
	push offset lpFindFile.cFileName
	push [ebp + 12]
	call lstrcat 
	
	PUSH  [ebp + 12]
	call lstrlen							; eax bang do dai dirName
	
	inc eax
	lea edx, [ebp + 12]
	mov byte ptr [edx + eax], 5ch				; 0 thanh *
	inc eax
	mov byte ptr [edx + eax], 0				; vi tri cuoi string thanh null
	
	push [ebp + 12]
	push [ebp + 8]
	call FindFile
	
	;-----------TIM FILE TIEP THEO
	
_loop1:

	push [ebp + 8]							;lpFindFile
	push [ebp - 4]							;push hFile
	call FindNextFile
	
	cmp eax, 0								;Kiem tra xem da het file chua
	je _return1
	
	;----------GHI VAO FILE
	push offset lpFindFile.cFileName	;fileName
	push offset szOutputPath				;out.txt
	call WriteFileOutput
	
	push offset newLine					; new line
	push offset szOutputPath				;out.txt
	call WriteFileOutput
	
	mov eax, lpFindFile.dwFileAttributes
	cmp eax, 10h							;the handle that identifies a directory
	jne _loop1								; neu k phai folder thi find next file
	
	;----------DOI DUONG DAN VA GOI LAI
	
	PUSH  [ebp + 12]
	call lstrlen							; eax bang do dai dirName
	
	lea edx, [ebp + 12]
	
	mov byte ptr [edx + eax], 5ch				; * thanh \
	
	push offset lpFindFile.cFileName
	push [ebp + 12]
	call lstrcat 
	
	PUSH  [ebp + 12]
	call lstrlen							; eax bang do dai dirName
	
	inc eax
	lea edx, [ebp + 12]
	mov byte ptr [edx + eax], 5ch				; 0 thanh *
	inc eax
	mov byte ptr [edx + eax], 0				; vi tri cuoi string thanh null
	
	push [ebp + 12]
	push [ebp + 8]
	call FindFile
_return1:
	
_exit1:
	push [ebp - 4]							;push hFile
	call FindClose							
	leave
	ret 8

FindFile endp

OpenAPP proc
	push ebp
	mov ebp, esp
	
	push [ebp + 28]
	push [ebp + 24]
	push [ebp + 20]
	push [ebp + 16]
	push [ebp + 12]
	push [ebp + 8]
	call ShellExecute
	leave
	ret 24

OpenAPP endp

ReadFileInput proc
	; tham so: szInputString, szInputPath
	
	;LOCAL hHandleFileInput:dword 	[ebp - 4]	; Bien cuc bo kieu dword
	;LOCAL FileSizeHigh:dword	[ebp - 8]
	;LOCAL FileSize:dword		[ebp - 12]		; Bien cuc bo chua kich thuoc file	
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
	push 80000000h				;GENERIC_READ
	push eax
	call CreateFile				; ket qua tra ve eax, chua dia chi offset file

	mov  [ebp - 4], eax				;dua gia tri eax vao bien cuc bo hHandleFileInput
	cmp  eax, -1			;kiem tra eax voi gia tri khong hop le
	je	 errReadFileText				; nhay den ham thong bao loi neu bang
	
	lea  eax, [ebp - 8]				; load dia chi bien FileZiseHigh vao eax
	push eax						; push filesizehigh
	push [ebp - 4]					;push handle file input
	call GetFileSize 				; kich thuoc file tra ve eax
	mov  [ebp - 12], eax				; dua eax vao stack [ebp - 8]
	
	push 0
	lea  eax, [ebp - 16]			;byteread
	push eax
	push [ebp - 12]					;FileSize
	mov eax, [ebp + 12]				;InputString
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

ReadFileInput endp

WriteFileOutput proc
	;tham so: ; tham so: szOutputString, szOutputPath
	
	;LOCAL hHandleFileInput:dword 	[ebp - 4]				; Bien cuc bo kieu dword
	;LOCAL BufferLength : dword  [ebp - 8]
	;LOCAL nByteWrite:dword     [ebp - 12]
	push ebp 
	mov ebp, esp
	add esp, -0Ch
	
	mov eax, [ebp + 8]						;outputPath
	push 0
	push 0
	push 3h
	push 0
	push 1h
	push 40000000h							;GENERIC_WRITE
	push eax
	Call CreateFile
	
	mov  [ebp - 4], eax						; eax vao handleFileInput
	cmp  eax, -1							;gia tri eax khong hop le
	je	 _errWriteFileText

	
	push FILE_END
	push 0
	push 0
	push [ebp - 4]							;handleFileInput
	call SetFilePointer
	
	push [ebp + 12]							; outputString
	call lstrlen
	mov  [ebp - 8], eax						;eax vao bufferLength
	
	push 0
	lea  eax, [ebp - 12]					;bytewrite vao eax
	push eax
	push [ebp - 8]							;bufferLength
	push [ebp + 12]							; outputString
	push [ebp - 4]							;handleFileInput
	Call WriteFile 
	
	push [ebp - 4]							;handleFileInput
	call CloseHandle
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