;imports
extern _printf
extern _GetStdHandle@4
extern _GetConsoleScreenBufferInfo@8
extern _SetConsoleCursorInfo@8
extern _ExitProcess@4
extern _GetSystemDefaultLangID@0
extern _GetLastError@0
extern _FormatMessageA@28
extern _GetProcessHeap@0
extern _HeapFree@12
extern _WriteFile@20
extern _SetConsoleCursorPosition@8
extern _FillConsoleOutputCharacterA@20

section .data
    ;constants
    NULL  equ 0
    FALSE equ 0
    TRUE  equ 1

    STD_INPUT_HANDLE  equ    -10
    STD_OUTPUT_HANDLE equ    -11
    STD_ERROR_HANDLE  equ    -12 ; https://learn.microsoft.com/en-us/windows/console/getstdhandle#parameters

    ; FormatMessage https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage#parameters
    FORMAT_MESSAGE_ALLOCATE_BUFFER equ 0x00000100
    FORMAT_MESSAGE_ARGUMENT_ARRAY  equ 0x00002000
    FORMAT_MESSAGE_FROM_HMODULE    equ 0x00000800
    FORMAT_MESSAGE_FROM_STRING     equ 0x00000400
    FORMAT_MESSAGE_FROM_SYSTEM     equ 0x00001000
    FORMAT_MESSAGE_IGNORE_INSERTS  equ 0x00000200

    FORMAT_MESSAGE_NORMAL          equ FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS 

    ;stuff

    hStdOut            dd 0
    hStdErr            dd 0
    hStdIn             dd 0

    hCurrentOut        dd 0

    screenBufferWidth  dw 0 ; this is the entire terminal
    screenBufferHeight dw 0

    windowWidth        dw 0 ; this is what is visible
    windowHeight       dw 0


    decCharBuffer      times 10 db 0
    decCharBufferLen   equ ($ - decCharBuffer)

    errorHappend      db "An error has occured: ", 0

    

section .text

addx:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]  ; the first argument (value)
    mov ebx, [ebp+12] ; the second argument (x)

    add eax, ebx

    mov esp, ebp
    pop ebp
    ret




; CONSOLE STUFF
InitConsole:
    push ebp
    mov ebp, esp ; the prologue :sus

    push STD_OUTPUT_HANDLE
    call _GetStdHandle@4
    mov [hStdOut], eax ; *hStdOut = GetStdHandle(-11)
    mov [hCurrentOut], eax

    push STD_ERROR_HANDLE 
	call _GetStdHandle@4
	mov [hStdErr], eax

    push STD_INPUT_HANDLE
	call _GetStdHandle@4
	mov [hStdIn], eax

    sub esp, 24 ; WE are allocating space for CONSOLE_SCREEN_BUFFER_INFO.
                ; we pass esp as the 2nd argument and then the function will populate it with the properties
	push esp
	push dword [hCurrentOut]
    call _GetConsoleScreenBufferInfo@8
    test eax, eax
	jz Error

    ; https://learn.microsoft.com/en-us/windows/console/console-screen-buffer-info-str#syntax
    ; COORD is a (x,y) structure where x and y are shorts so 2 bytes

    ; COORD {
    ;   WORD X; 0
    ;   WORD Y; 2
    ; } 4

    ; using ax because it is 16 bits and CONSOLE_SCREEN_BUFFER_INFO structure contains members that are 16-bit values
    mov ax, word [esp]   ; dwSize.X
	mov word [screenBufferWidth], ax
	mov ax, word [esp+2] ; dwSize.Y
	mov word [screenBufferHeight], ax



    ; https://learn.microsoft.com/en-us/windows/console/console-screen-buffer-info-str#syntax
    ; _CONSOLE_SCREEN_BUFFER_INFO {
    ;     COORD      dwSize; 0
    ;     COORD      dwCursorPosition; 4
    ;     WORD       wAttributes; 8
    ;     SMALL_RECT srWindow; 10
    ;     COORD      dwMaximumWindowSize; 18
    ; } CONSOLE_SCREEN_BUFFER_INFO; 22


    ; https://learn.microsoft.com/en-us/windows/console/small-rect-str#syntax
    ; _SMALL_RECT {
    ;     SHORT Left; 0
    ;     SHORT Top; 2
    ;     SHORT Right; 4 ; WE WNAT THIS sooo 10+4 = 14; 14 is the offset for right
    ;     SHORT Bottom; 6 ; AND THIS sooo 10+6 = 16; 16 is the offset for bottom
    ; } SMALL_RECT; 8

    mov ax, word [esp+14] ; srWindow.Right
    mov word [windowWidth], ax

    mov ax, word [esp+16] ; srWindow.Bottom
    mov word [windowHeight], ax


    ; disable cursor

    ; https://learn.microsoft.com/en-us/windows/console/console-cursor-info-str#syntax
    ; _CONSOLE_CURSOR_INFO {
    ;     DWORD dwSize; 0
    ;     BOOL  bVisible; 4
    ; } CONSOLE_CURSOR_INFO, *PCONSOLE_CURSOR_INFO; 8

    sub esp, 8 ; allocate 8 bytes for _CONSOLE_CURSOR_INFO
    mov dword [esp], 1 ; dwSize
    mov dword [esp+4], FALSE ; bVisible

    push esp
    push dword [hCurrentOut]
    call _SetConsoleCursorInfo@8
    

    ; free the 8 bytes
    add esp, 8

    mov esp, ebp ; the epilogue
    pop ebp
    ret


StrLen:
    push ebp
    mov ebp, esp

    mov edx, [ebp+8]  ; the first argument (str)
    mov edi, 0        ; i =  0
_loop:
    cmp byte [edx+edi], 0
    je _exit_strlen
    add edi, 1
    jmp _loop

_exit_strlen:
    mov eax, edi ; make return value equal the fuckinnn i or length of the string

    mov esp, ebp
    pop ebp
    ret


PrintString:
    push ebp
	mov ebp, esp

    push dword [ebp+8] ; first arg (char* message with null terminator) 
	call StrLen

    push eax
    push dword [ebp+8]
    call PrintStrLen

    mov esp, ebp
    pop ebp
	ret



PrintStrLen: ; PrintStrLen(char* msg, int len)
    push ebp
    mov ebp, esp ; the prologue :sus

    push 0,
    push 0,
    push dword [ebp+12]
    push dword [ebp+8]
    push dword [hCurrentOut]
    call _WriteFile@20

    mov esp, ebp ; the epilogue
    pop ebp
    ret


PrintStrLenAtPos:
    push ebp
    mov ebp, esp

    push dword [ebp+16] ; COORD pos
	push dword [hCurrentOut] ; hConsole
	call _SetConsoleCursorPosition@8
    test eax, eax
	jz Error

    push dword [ebp+12] ; int len
    push dword [ebp+8] ; char* messaag
    call PrintStrLen

    mov esp, ebp
    pop ebp
    ret


PrintStrAtPos:
    push ebp
    mov ebp, esp

    push dword [ebp+12] ; COORD pos
	push dword [hCurrentOut] ; hConsole
	call _SetConsoleCursorPosition@8
    test eax, eax
	jz Error

    push dword [ebp+8] ; char* messaag
    call PrintString

    mov esp, ebp
    pop ebp
    ret


PrintDec: ; eax = integer to write
    push ebp
    mov ebp, esp


	push edi
	mov edi, (decCharBufferLen-1)
	
	.write_reminder:
		xor edx, edx
		mov ecx, 10 
		div ecx			; edx = char, eax = quotient
		or dl, 0x30 ; ascii on
		mov byte [decCharBuffer+edi], dl 
		dec edi
		test eax, eax
		jnz .write_reminder
	
	inc edi
	mov eax, decCharBufferLen
	sub eax, edi
	push eax ; len
	lea eax, [decCharBuffer+edi]
	push eax ; msg
	call PrintStrLen
	pop edi
	

    
    mov esp, ebp
    pop ebp
    ret

PrintDecPos:
    push ebp
    mov ebp, esp

    push dword [ebp+8] ; integer value
    push dword [ebp+12]  ; position
    push dword [hCurrentOut]
    call _SetConsoleCursorPosition@8
    test eax, eax
    jz Error

    pop eax
    call PrintDec

    mov esp, ebp
    pop ebp
    ret


ClearConsole:
	push ebp
	mov ebp, esp

	sub esp, 4 ; making space for lpNumberOfCharsWritten. FillConsoleOutputCharacter(..., _Out_ LPDWORD lpNumberOfCharsWritten)
	lea eax, [ebp-4]
	push eax
	push dword 0 ; coord {0, 0}
	movzx eax, word [screenBufferWidth] 
	movzx ecx, word [screenBufferHeight] 
	mul ecx
	push eax
	push dword ' ' ; cCharacter
	push dword [hCurrentOut] ; hConsole
	call _FillConsoleOutputCharacterA@20
	test eax, eax
	jz Error
	push dword 0 ; coord {0, 0}
	push dword [hCurrentOut] ; hConsole
	call _SetConsoleCursorPosition@8
	
    mov esp, ebp
    pop ebp
    ret


; ERROR STUFF

Error:
    push errorHappend
    call PrintString
    call GetLastErrorMessage

    jmp ExitApp


ExitApp:
	push 0
	jmp _ExitProcess@4

GetLastErrorMessage:
	push ebp
	mov ebp, esp
	sub esp, 4 ; LPSTR lpBuffer;
	push NULL ; Arguments
	push 0 ; nSize
	lea eax, [ebp-4] ; lpBuffer
	push eax
	call _GetSystemDefaultLangID@0
	push eax ; dwLanguageId
	call _GetLastError@0
	push eax ; dwMessageId
	push NULL ; lpSource
	push FORMAT_MESSAGE_NORMAL	; dwFlags
	call _FormatMessageA@28
	
	mov eax, dword [hStdErr]
	mov dword [hCurrentOut], eax
	push dword [ebp-4] ; msg
	call PrintString
	mov eax, [hStdOut]
	mov [hCurrentOut], eax
	
	push dword [ebp-4] ; lpMem
	push dword 0 ; dwFlags
	call _GetProcessHeap@0
	push eax ; hHeap
	call _HeapFree@12
	
	leave
	ret


