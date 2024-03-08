global _main
extern _Sleep@4
%include "../utils/console.asm"
%include "../utils/input.asm"

section .data
    SLEEP_TIME equ 50

    VK_LEFT equ 25H
    VK_D equ 44H

    VK_RIGHT equ 27H
    VK_A equ 1EH

    PLAYER_SPEED equ 10

    PLAYER_WIDTH equ 26
    PLAYER_WIDTH_HALF equ PLAYER_WIDTH / 2
    player db PLAYER_WIDTH dup(219), 0
    playerPos dd 0 ; COORD {x, y}

    ball db 'o', 0
    ballPos dd 0 ; COORD {x, y}

    ballYVelocity dw 1
    ballXVelocity dw 0


    colided_blocks_x times 999 db 0 ; buffer overflow moment
    colided_blocks_y times 999 db 0 ; buffer overflow moment
    block_states     times 999 db 0 ; buffer overflow moment
    
    
    BLOCK_WIDTH equ 20
    BLOCK_DEPTH equ 2
    BLOCK_GAP_SUM equ (BLOCK_WIDTH + MIN_GAP * 2)
    MIN_GAP equ 2

    block db BLOCK_WIDTH dup(219), 0
    gap db MIN_GAP dup(' '), 0
    blockCount dd 0 
    blockCounter dd 0
    blockYCounter dw 0

    debugCoordx db 'x: ', 0
    debugCoordy db 'y: ', 0
    debugInt db 'int: %d', 10, 0

    debugValue dd 0

    newLine db 13, 10, 0
    gameOver db 'Game Over', 0

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

    ; mov [block_states+((i*5)+(j*4)) * 2], word 1
    mov [block_states+((1*5)+(1*2)) * 2], word 1
    mov [block_states+((0*5)+(1*2)) * 2], word 1
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
        call BlockStep

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

BlockStep:
    push ebp
    mov ebp, esp
    
    mov word [blockYCounter], 0
    .loop2:
        mov ax, word [blockYCounter]
        cmp ax, (BLOCK_DEPTH * 2)
        jg .end

        push ax
        call PrintBlocks

        add word [blockYCounter], 2
        jmp .loop2

    .end:

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
        


        ; add eax, ((BLOCK_WIDTH / 4) - MIN_GAP / 2) ; left offset
        
        movzx ebx, word [windowWidth]
        sub ebx, BLOCK_WIDTH
        cmp eax, ebx
        jge .end



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

    cmp bx, 0
    jle .bounceY

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
        cmp ecx, (BLOCK_DEPTH * 2)
        jg .continue

        ; check if y is even. we only have blocks in even rows
        test ecx, 1
        jne .continue

        movzx eax, word [ballPos] ; x
        xor edx, edx
        mov ebx, BLOCK_GAP_SUM
        div ebx

        cmp edx, BLOCK_WIDTH
        jae .continue

        mov ebx, eax
        shl ebx, 1
        shl ebx, 1 ; * word

        mov esi, colided_blocks_x
        add esi, ebx

        cmp word [esi], word 1
        jne .check_y

        movzx ebx, word [ballPos+2] ; y
        shl ebx, 2 ; * 4
        shl ebx, 1 ; * word
        mov esi, colided_blocks_y
        add esi, ebx
        cmp word [esi], word 1
        je .continue

        ; cmp word [colided_blocks+eax], word 1
        ; je .continue
        
        .check_y:
        mov [esi], word 1
        movzx ebx, word [ballPos+2] ; y
        shl ebx, 2 ; * 4
        mov esi, colided_blocks_y
        add esi, ebx

        ; cmp word [esi], word 1
        ; je .continue

        mov [esi], word 1
        jmp .bounceY

    jmp .continue

    .bounceWithXVelocity:
        mov cx, word [ballPos]
        sub cx, word [playerPos]
        cmp cx, PLAYER_WIDTH_HALF
        je .bounceY
        jg .go_right
        jl .go_left

        .go_right:
            mov [ballXVelocity], word 1
            jmp .bounceY

        .go_left:
            neg cx
            mov [ballXVelocity], word -1
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
        ; mov eax, 1
        ; jmp .return
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