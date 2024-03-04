global _main
extern _Sleep@4
%include "../utils/console.asm"
%include "../utils/input.asm"

section .data
    SLEEP_TIME equ 20

    VK_LEFT equ 25H
    VK_D equ 44H

    VK_RIGHT equ 27H
    VK_A equ 1EH

    PLAYER_WIDTH equ 15
    PLAYER_WIDTH_HALF equ PLAYER_WIDTH / 2
    player db PLAYER_WIDTH dup(219), 0
    playerPos dd 0 ; COORD {x, y}

    ball db 'o', 0
    ballPos dd 0 ; COORD {x, y}

    ballYVelocity dw -1
    ballXVelocity dw 0

    debugCoordx db 'x: ', 0
    debugCoordy db 'y: ', 0

    newLine db 13, 10, 0
    gameOver db 'Game Over', 0

section .text

_main:
    call InitConsole
    call ClearConsole

    call GameMain

    xor eax, eax
    ret


GameMain:
    call InitPlayerPos
    call InitBallPos

    .game_loop:
        call ClearConsole

        call ProcessInput
        call BallStep
        test eax, eax
        jnz .exit

        push dword [playerPos]
        push player
        call PrintStrAtPos

        push dword [ballPos]
        push ball
        call PrintStrAtPos

        call GameSleep
        jmp .game_loop

    .exit:
        push dword newLine
        call PrintString

        push dword gameOver
        call PrintString
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

    push ax ; x (centered)
    push word [windowHeight] ; y (bottom)
    call SetCoord

    mov [playerPos], eax

    mov esp, ebp
    pop ebp
    ret

InitBallPos:
    push ebp
    mov ebp, esp

    mov ax, [windowWidth]
    mov bx, 2
    xor edx, edx
    div bx

    push ax ; x

    mov ax, [windowHeight]
    mov bx, 2
    xor edx, edx
    div bx

    push ax ; y
    call SetCoord

    mov [ballPos], eax

    mov esp, ebp
    pop ebp
    ret

ProcessInput:
    push ebp
    mov ebp, esp

    call GetLastKey
    cmp [isKeyDown], word TRUE
    jne .return

    cmp ax, VK_LEFT
    je .move_left
    cmp ax, VK_A
    je .move_left

    cmp ax, VK_RIGHT
    je .move_right
    cmp ax, VK_D
    je .move_right
    

    .move_left:
        mov eax, [playerPos]
        sub eax, 1
        mov [playerPos], eax
        jmp .return

    .move_right:
        mov eax, [playerPos]
        add eax, 1
        mov [playerPos], eax
        jmp .return

    .return:
        mov esp, ebp
        pop ebp
        ret

BallStep:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov ax, word [ballPos] ; x
    mov bx, word [ballPos+2] ; y    

    add ax, word [ballXVelocity]
    add bx, word [ballYVelocity]

    mov [ballPos], ax
    mov [ballPos+2], bx

    ; mov ax, bx
    ; call PrintDec

    cmp bx, 0
    jle .bounce

    mov cx, [windowHeight]
    sub cx, 1
    cmp bx, cx
    jge .check_player_colision

    jmp .continue

    .check_player_colision:
        mov ax, word [playerPos] ; x
        xor ecx, ecx
        cmp ax, word [ballPos]
        je .bounce
        .player_width_check: ; while ecx < PLAYER_WIDTH
            cmp ecx, PLAYER_WIDTH
            jg .game_over

            add ax, 1
            cmp ax, word [ballPos]
            je .bounce

            inc ecx
            jmp .player_width_check


    jmp .continue

    .bounce:
        neg word [ballYVelocity]
        jmp .continue

    .game_over:
        mov eax, 1
        jmp .return

    .continue:
        xor eax, eax

    .return:
    mov esp, ebp
    pop ebp
    ret

; utils
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