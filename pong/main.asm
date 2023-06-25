global _main
extern _GetStdHandle@4
extern _WriteFile@20
extern _SetConsoleTextAttribute@8

section .data
    ; Constnats

    COLOR_BLACK equ 0x00
    COLOR_BLUE equ 0x01
    COLOR_GREEN equ 0x02
    COLOR_CYAN equ 0x03
    COLOR_RED equ 0x04
    COLOR_MAGENTA equ 0x05
    COLOR_YELLOW equ 0x06
    COLOR_WHITE equ 0x07

    STD_INPUT_HANDLE  equ    -10
    STD_OUTPUT_HANDLE equ    -11
    STD_ERROR_HANDLE  equ    -12 ; https://learn.microsoft.com/en-us/windows/console/getstdhandle#parameters

    ; GLOBALS GANG
    stdOutHandle dd 0


    welcomeMessage db "good day kind sir", 10, 0
    welcomeMessageLen equ ($ - welcomeMessage - 1)
section .text

_main:
    push ebp
    mov ebp, esp ; the prologue :sus

    call InitConsole

    push COLOR_BLUE
    call SetConsoleColor

    push welcomeMessageLen
    push welcomeMessage
    call PrintStrLen

    push COLOR_WHITE
    call SetConsoleColor

    push welcomeMessageLen
    push welcomeMessage
    call PrintStrLen

    mov eax, 0 ; make the return value for main be 0

    mov esp, ebp ; the epilogue
    pop ebp
    ret


InitConsole:
    push STD_OUTPUT_HANDLE
    call _GetStdHandle@4

    mov [stdOutHandle], eax ; *stdOutHandle = GetStdHandle(-11)

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

    ; ; Restore the original text color (0x07)
    ; push dword 0x07
    ; push dword [stdOutHandle]
    ; call _SetConsoleTextAttribute@8

    mov esp, ebp ; the epilogue
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
