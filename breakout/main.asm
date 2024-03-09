global _main
extern _Sleep@4
%include "../utils/console.asm"
%include "../utils/input.asm"

section .data
    SLEEP_TIME equ 25

    VK_LEFT equ 25H
    VK_D equ 44H

    VK_RIGHT equ 27H
    VK_A equ 1EH

    PLAYER_SPEED equ 13

    PLAYER_WIDTH equ 28
    PLAYER_WIDTH_HALF equ PLAYER_WIDTH / 2
    player db PLAYER_WIDTH dup(219), 0
    playerPos dd 0 ; COORD {x, y}

    ball db 'o', 0
    ballPos dd 0 ; COORD {x, y}

    ballYVelocity dw 1
    ballXVelocity dw 0
    ANGLE_FACTOR equ 1

    color_arr dd COLOR_RED, COLOR_GREEN, 0, COLOR_YELLOW ; we dont talk the 0

    colided_blocks_x times 999 db 0 ; buffer overflow moment
    colided_blocks_y times 999 db 0 ; buffer overflow moment
    block_states     times 999 db 0 ; buffer overflow moment
    
    
    BLOCK_WIDTH equ 24
    BLOCK_DEPTH equ 2
    MIN_GAP equ 4
    BLOCK_GAP_SUM equ (BLOCK_WIDTH + MIN_GAP * 2)
    LEFT_OFFSET equ BLOCK_WIDTH - MIN_GAP * 2

    block db BLOCK_WIDTH dup(219), 0
    gap db MIN_GAP dup(' '), 0
    blockCount dd 0 
    blockCounter dd 0
    blockYCounter dw 0
    visibleBlockCount dd -1

    debugCoordx db 'x: ', 0
    debugCoordy db 'y: ', 0
    debugInt db 'int: %d', 10, 0

    debugValue dd 0

    newLine db 13, 10, 0
    gameOver db 'Game Over', 0
    youWin db 'You Win', 0

section .text

_main:
    call InitConsole
    call ClearConsole

    ; mov [colided_blocks_x+(0*2) * 2], word 1
    ; mov [colided_blocks_y+(0*4) * 2], word 1


    ; mov [colided_blocks_x+(4*2) * 2], word 1
    ; mov [colided_blocks_y+(2*4) * 2], word 1

    ; mov [colided_blocks_x+(2*2) * 2], word 1
    ; mov [colided_blocks_y+(4*4) * 2], word 1

    ; mov [block_states+((i*5)+(j*2)) * 2], word 1
    ; mov [block_states+((2*5)+0) * 2], word 1
    ; mov [block_states+((0*5)+((0*2)- 1)) * 2], word 1
    ; mov [block_states+((0*5)+0) * 2], word 1

    ; mov [colided_blocks+0*4*1], dword 1
    ; push 0
    ; call PrintBlocks

    ; push newLine
    ; call PrintString
    
    ; movzx eax, word [windowWidth]
    ; call PrintDec

    ; push dword newLine
    ; call PrintString

    ; mov eax, [blockCount]
    ; call PrintDec
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
        jnz .game_over2

        call BlockStep

        call CheckWinCondition
        cmp eax, 1
        je .win

        call PrintPlayer
        call PrintBall

        call GameSleep
        jmp .game_loop

    .game_over2:
        push dword newLine
        call PrintString

        push dword gameOver
        call PrintString
        ret

    .win:
        push dword newLine
        call PrintString

        push dword youWin
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

PrintPlayer:
        push ebp
        mov ebp, esp

        push dword [playerPos]
        push player
        call PrintStrAtPos
        
        leave
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

PrintBall:
    push ebp
    mov ebp, esp

    push dword [ballPos]
    push ball
    call PrintStrAtPos

    mov esp, ebp
    pop ebp
    ret

CheckWinCondition:
    push ebp
    mov ebp, esp

    cmp [visibleBlockCount], dword 0
    je .win

    mov eax, 0
    jmp .return2

    .win:
    mov eax, 1

    .return2:
    mov esp, ebp
    pop ebp
    ret


BlockStep:
    push ebp
    mov ebp, esp
    
    mov word [blockYCounter], 0
    mov [visibleBlockCount], dword 0
    mov ecx, 0
    .loop2:
        push dword [color_arr+ecx*4]
        call SetConsoleColor

        mov ax, word [blockYCounter]
        cmp ax, (BLOCK_DEPTH * 2)
        jg .end


        push ax
        call PrintBlocks

        add word [blockYCounter], 2
        inc ecx
        jmp .loop2

    .end:

    push COLOR_WHITE
    call SetConsoleColor

    mov esp, ebp
    pop ebp
    ret

PrintBlocks:
    push ebp
    mov ebp, esp

    ; xor eax, eax
    ; movzx eax, word [windowWidth]
    ; ; call PrintDec
    ; sub eax, (MIN_GAP * 2)
    ; mov ebx, (BLOCK_WIDTH + MIN_GAP * 4)
    ; xor edx, edx
    ; div ebx
    ; mov [blockCount], eax

    ; call PrintDec
    ; jmp .end
    mov dword [blockCounter], 0
    .loop:
        
        ; check if block is out of bounds
        ; mov ecx, dword [blockCounter]
        ; mov eax, (BLOCK_WIDTH + MIN_GAP * 4)
        ; mul ecx
        ; mov [debugValue], eax

        ; add eax, 
        ; cmp eax, [windowWidth]
        ; jge .end

        ; shl eax, 1
        ; mov eax, dword [blockCounter]
        ; shl eax, 1
        ; cmp [colided_blocks_x+(eax*2)], word 1
        ; jne .print

        ; movzx ebx, word [ebp+8]
        ; shl ebx, 2
        ; cmp [colided_blocks_y+(ebx*2)], word 1
        ; jne .print

        mov eax, dword [blockCounter]
        mov ebx, BLOCK_DEPTH * 2 + 1
        mul ebx

        movzx ecx, word [ebp+8]
        add eax, ecx
        shl eax, 1

        cmp [block_states+eax], word 1
        jne .print
        
        jmp .continue
        
        .print:
        mov eax, dword [blockCounter]
        mov ebx, BLOCK_GAP_SUM
        mul ebx
        


        add eax, LEFT_OFFSET
        
        movzx ebx, word [windowWidth]
        sub ebx, BLOCK_WIDTH
        cmp eax, ebx
        jge .end


        inc dword [visibleBlockCount]
        push eax
        push word [ebp+8]
        call SetCoord

        push eax
        push block
        call PrintStrAtPos

        ; push block
        ; call PrintString

        ; push gap
        ; call PrintString

        .continue:
        inc dword [blockCounter]
        jmp .loop

    .end:

    mov eax, dword [blockCounter]
    mov [blockCount], eax

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
        mov ax, [playerPos]
        sub ax, PLAYER_SPEED
        cmp ax, 0
        jle .return

        mov word [playerPos], ax
        jmp .return

    .move_right:
        mov eax, [playerPos]
        add eax, PLAYER_SPEED
        add eax, PLAYER_WIDTH
        cmp ax, word [windowWidth]

        jge .return
        sub ax, PLAYER_WIDTH ; very hacky
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

    mov cx, [windowHeight]
    sub cx, 1
    cmp bx, cx
    jge .check_player_colision

    cmp ax, 0
    jle .bounceX

    mov cx, [windowWidth]
    sub cx, 1
    cmp ax, cx
    jge .bounceX
    
    jmp .check_block_colision

    .check_player_colision:
        mov ax, word [ballPos] ; x

        cmp ax, word [playerPos]
        jle .game_over

        mov bx, word [playerPos]
        add bx, (PLAYER_WIDTH + 1)
        cmp ax, bx
        jge .game_over

        jmp  .bounceWithXVelocity


    .check_block_colision:

        xor ecx, ecx
        movzx ecx, word [ballPos+2] ; y
        cmp ecx, (BLOCK_DEPTH * 2) + 1
        jge .continue


        ; check if y is even. we only have blocks in even rows
        test ecx, 1
        jne .continue

        movzx eax, word [ballPos] ; x
        sub eax, LEFT_OFFSET

        ; check for 0
        test eax, eax
        jl .check_top

        xor edx, edx
        mov ebx, BLOCK_GAP_SUM
        div ebx

        cmp edx, BLOCK_WIDTH
        jae .check_top

        mov ebx, BLOCK_DEPTH * 2 + 1
        mul ebx
        xor ecx, ecx
        movzx ecx, word [ballPos+2]

        add eax, ecx
        shl eax, 1

        cmp [block_states+eax], word 1
        je .check_top

        mov [block_states+eax], word 1
        jmp .bounceY

    jmp .continue

    .check_top:
        mov bx, word [ballPos+2]
        cmp bx, 0
        jle .bounceY
        jmp .continue

    .bounceWithXVelocity:
        mov cx, word [ballPos]
        sub cx, word [playerPos]

        cmp cx, PLAYER_WIDTH_HALF
        je .bounceY
        jg .go_right
        jl .go_left

        .go_right:
            mov [debugValue], word 1
            jmp .angle_calc
            
        .go_left:
            mov [debugValue], word -1
        
        .angle_calc:
        add cx, PLAYER_WIDTH_HALF

        mov ax, cx
        neg ax
        sbb ax, -1 ; subtract with borrow
        and ax, cx
        add ax, cx

        mov ax, ANGLE_FACTOR
        imul cx
        
        mov bx, PLAYER_WIDTH_HALF
        idiv bx

        mov ebx, dword [debugValue]
        mul ebx

        mov [ballXVelocity], ax
        jmp .bounceY


    .bounceY:
        neg word [ballYVelocity]
        jmp .continue

    .bounceX:
        cmp [ballXVelocity], word 0
        jl .left

        .right:
            mov ax, [windowWidth]
            sub ax, 1
            mov [ballPos], ax
            neg word [ballXVelocity]
            jmp .continue

        .left:
            mov [ballPos], word 0
            neg word [ballXVelocity]

        jmp .continue

    .game_over:
        mov eax, 1
        jmp .return
        jmp .bounceY

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