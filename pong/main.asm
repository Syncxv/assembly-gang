global _main
extern _GetStdHandle@4
extern _WriteFile@20
extern _SetConsoleTextAttribute@8
extern _GetConsoleScreenBufferInfo@8
extern _FillConsoleOutputCharacterA@20
extern _SetConsoleCursorPosition@8
extern _Sleep@4

extern _GetLastError@0
extern _FormatMessageA@28
extern _HeapFree@12
extern _GetProcessHeap@0
extern _ExitProcess@4

; extern _printf

section .data
    ; Constnats
    NULL  equ 0
    FALSE equ 0
    TRUE  equ 1


    COLOR_BLACK   equ 0x00
    COLOR_BLUE    equ 0x01
    COLOR_GREEN   equ 0x02
    COLOR_CYAN    equ 0x03
    COLOR_RED     equ 0x04
    COLOR_MAGENTA equ 0x05
    COLOR_YELLOW  equ 0x06
    COLOR_WHITE   equ 0x07

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


    ; GLOBALS GANG
    sleepTime          dd 100

    stdOutHandle       dd 0
    screenBufferWidth  dw 0 ; this is the entire terminal
    screenBufferHeight dw 0

    windowWidth        dw 0 ; this is what is visible
    windowHeight       dw 0

    errorCode          dd 0 ; 4 bytes dword

    bruh               dd "val: %d", 10, 0



    welcomeMessage db "good day kind sir", 10, 0
    welcomeMessageLen equ ($ - welcomeMessage - 1)
section .text

_main:
    push ebp
    mov ebp, esp ; the prologue :sus

    call InitConsole

    call ClearConsole

    push COLOR_BLUE
    call SetConsoleColor

    push welcomeMessageLen
    push welcomeMessage
    call PrintStrLen

    push COLOR_WHITE
    call SetConsoleColor


    push welcomeMessage
    call PrintString
    
    ; movzx ecx, word [windowWidth]
    ; push ecx
    ; push bruh
    ; call _printf

    call GameMain

    mov eax, 0 ; make the return value for main be 0

    mov esp, ebp ; the epilogue
    pop ebp
    ret


GameMain:

    .game_loop:
        ; call ClearConsole


        
        ; push 1
        ; push ecx
        ; call PrintStrLen


        call SleepGame

        jmp .game_loop


SleepGame:
    push dword [sleepTime]
    call _Sleep@4

    ret

; CONSOLE STUFF
InitConsole:
    push ebp
    mov ebp, esp ; the prologue :sus

    push STD_OUTPUT_HANDLE
    call _GetStdHandle@4

    mov [stdOutHandle], eax ; *stdOutHandle = GetStdHandle(-11)

    sub esp, 24 ; WE are allocating space for CONSOLE_SCREEN_BUFFER_INFO.
                ; we pass esp as the 2nd argument and then the function will populate it with the properties
	push esp
	push dword [stdOutHandle]
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

    ; https://learn.microsoft.com/en-us/windows/console/small-rect-str#syntax
    ; _SMALL_RECT {
    ;     SHORT Left; 0
    ;     SHORT Top; 2
    ;     SHORT Right; 4 ; WE WNAT THIS sooo 10+4 = 14; 14 is the offset for right
    ;     SHORT Bottom; 6 ; AND THIS sooo 10+6 = 16; 16 is the offset for bottom
    ; } SMALL_RECT; 8


    ; https://learn.microsoft.com/en-us/windows/console/console-screen-buffer-info-str#syntax
    ; _CONSOLE_SCREEN_BUFFER_INFO {
    ;     COORD      dwSize; 0
    ;     COORD      dwCursorPosition; 4
    ;     WORD       wAttributes; 8
    ;     SMALL_RECT srWindow; 10
    ;     COORD      dwMaximumWindowSize; 18
    ; } CONSOLE_SCREEN_BUFFER_INFO; 22



    mov ax, word [esp+14] ; srWindow.Right
    mov word [windowWidth], ax

    mov ax, word [esp+16] ; srWindow.Bottom
    mov word [windowHeight], ax


    mov esp, ebp ; the epilogue
    pop ebp
    ret

PrintStrLen: ; PrintStrLen(char* msg, int len)
    push ebp
    mov ebp, esp ; the prologue :sus

    push 0,
    push 0,
    push dword [ebp+12]
    push dword [ebp+8]
    push dword [stdOutHandle]
    call _WriteFile@20

    mov esp, ebp ; the epilogue
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

StrLen:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]  ; the first argument (str)
    mov ebx, 0        ; i =  0
_loop:
    cmp [eax+ebx], dword 0
    je _exit_strlen
    add ebx, 1
    jmp _loop

_exit_strlen:
    mov eax, ebx ; make return value equal the fuckinnn i or length of the string

    mov esp, ebp
    pop ebp
    ret


SetConsoleColor: ; SetConsoleColor(int Color)
    push ebp
    mov ebp, esp ; the prologue :sus

    push dword [ebp+8]
    push dword [stdOutHandle]
    call _SetConsoleTextAttribute@8

    mov esp, ebp ; the epilogue
    pop ebp
    ret


; https://github.com/repnz/snax86/blob/master/src/snax86.asm#L1059 i love this guy
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
	push dword [stdOutHandle] ; hConsole
	call _FillConsoleOutputCharacterA@20
	test eax, eax
	jz Error
	push dword 0 ; coord {0, 0}
	push dword [stdOutHandle] ; hConsole
	call _SetConsoleCursorPosition@8
	
    mov esp, ebp
    pop ebp
    ret

; ERROR STUFF

Error:
    call GetLastErrorMessage

    jmp ExitApp


ExitApp:
	push 0
	jmp _ExitProcess@4

GetLastErrorMessage:
    push ebp
    mov ebp, esp

    ; Call GetLastError to retrieve the last error code
    call _GetLastError@0

    ; Retrieve the error message
    push eax ; dwMessageId
	push NULL ; lpSource
	push FORMAT_MESSAGE_NORMAL	; dwFlags
	call _FormatMessageA@28

    ; Print the error message
    push eax ; lpBuffer
    call PrintString

    push dword [ebp-4] ; lpMem
	push dword 0 ; dwFlags
	call _GetProcessHeap@0
	push eax ; hHeap
	call _HeapFree@12
	
	leave
	ret

