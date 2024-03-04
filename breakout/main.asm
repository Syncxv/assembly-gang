global _main
%include "../consoleutils/main.asm"

section .data
    player db 15 dup(219), 0
    playerPos dd 0 ; COORD {x, y}

section .text

_main:
    call InitConsole
    call ClearConsole

    call InitPlayerPos

    xor eax, eax
    ret

InitPlayerPos:
    mov ax, [windowWidth]
    mov bx, 2
    xor edx, edx
    div bx

    push ax
    push word [windowHeight]
    call SetCoord

    mov [playerPos], eax

    push eax
    push player
    call PrintStrAtPos

SetCoord: ; [ebp+8] = y, [ebp+10] = x
    push ebp
    mov ebp, esp

    mov ax, word [ebp+10]

    shl eax, 16
    mov ax, [ebp+8]

    ror eax, 16
    
    mov esp, ebp
    pop ebp
    ret