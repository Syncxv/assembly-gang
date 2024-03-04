global _main
extern _Sleep@4
%include "../consoleutils/main.asm"

section .data
    SLEEP_TIME equ 5

    PLAYER_WIDTH equ 15
    PLAYER_WIDTH_HALF equ PLAYER_WIDTH / 2
    player db PLAYER_WIDTH dup(219), 0
    playerPos dd 0 ; COORD {x, y}

    ball db 'o', 0
    ballPos dd 0 ; COORD {x, y}

section .text

_main:
    call InitConsole
    call ClearConsole

    call GameMain

    xor eax, eax
    ret


GameMain:
    call InitPlayerPos

    .game_loop:
        call ClearConsole

        push dword [playerPos]
        push player
        call PrintStrAtPos

        push dword [ballPos]
        push ball
        call PrintStrAtPos

        call GameSleep
        jmp .game_loop

    .exit:
        ret

GameSleep:
    push dword SLEEP_TIME
    call _Sleep@4

    ret

InitPlayerPos:
    push ebp
    mov ebp, esp

    mov ax, [windowWidth]
    mov bx, 2
    xor edx, edx
    div bx

    sub ax, PLAYER_WIDTH_HALF

    push ax
    push word [windowHeight]
    call SetCoord

    mov [playerPos], eax

    mov esp, ebp
    pop ebp
    ret

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