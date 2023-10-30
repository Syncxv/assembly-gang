global _main
extern _GetStdHandle@4
extern _WriteFile@20
extern _SetConsoleTextAttribute@8
extern _GetConsoleScreenBufferInfo@8
extern _FillConsoleOutputCharacterA@20
extern _SetConsoleCursorPosition@8
extern _SetConsoleCursorInfo@8
extern _GetNumberOfConsoleInputEvents@8
extern _ReadConsoleInputA@16
extern _Sleep@4

extern _GetLastError@0
extern _FormatMessageA@28
extern _HeapFree@12
extern _GetProcessHeap@0
extern _ExitProcess@4
extern _GetSystemDefaultLangID@0

; extern _printf

section .data
    ; Constnats
    NULL  equ 0
    FALSE equ 0
    TRUE  equ 1

    VK_UP           equ 26H
    VK_DOWN         equ 28H
    VK_W            equ 57H
    VK_S            equ 53H

    COLOR_BLACK   equ 0x00
    COLOR_BLUE    equ 0x01
    COLOR_GREEN   equ 0x02
    COLOR_CYAN    equ 0x03
    COLOR_RED     equ 0x04
    COLOR_MAGENTA equ 0x05
    COLOR_YELLOW  equ 0x06
    COLOR_WHITE   equ 0x07

    ; https://learn.microsoft.com/en-us/windows/console/input-record-str#members
    FOCUS_EVENT 			 equ 0x0010
    KEY_EVENT   			 equ 0x0001
    MENU_EVENT  			 equ 0x0008
    MOUSE_EVENT 			 equ 0x0002
    WINDOW_BUFFER_SIZE_EVENT equ 0x0004

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
    sleepTime          dd 25

    hStdOut            dd 0
    hStdErr            dd 0
    hStdIn             dd 0

    hCurrentOut        dd 0




    screenBufferWidth  dw 0 ; this is the entire terminal
    screenBufferHeight dw 0

    windowWidth        dw 0 ; this is what is visible
    windowHeight       dw 0

    errorCode          dd 0 ; 4 bytes dword

    bruh               dd "val: 0x%08x", 10, 0
    ERROR_HAPPEND      dd "OH NO ERROR", 10, 0

    coordPosX          dw 0
    coordPosY          dw 0
    coord              dw 0, 0  ; COORD structure to store the position

    counter            dd 0

    lastKeyDown        dw 0
    isKeyDown          dw FALSE

    tempVar            dd 0

    decCharBuffer      times 10 db 0
    decCharBufferLen   equ ($ - decCharBuffer)

    welcomeMessage db "good day kind sir", 10, 0
    welcomeMessageLen equ ($ - welcomeMessage - 1)

    ball db 254, 0
    ballLen equ ($ - ball - 1)

    ballPos dd 0 ; CORD {x: 0, y: 0}
    ballXVelocity dw 1
    ballYVelocity dw 1

    player db 219, 0
    playerLen equ ($ - player - 1)
    playerHeight equ 6
    playerSpeed equ 1

    player1Pos dd 0 ; CORD {x: 0, y: 0}
    player2Pos dd 0 ; CORD {x: 0, y: 0}

    player1Score dd 0
    player1ScoreText db "Player 1 Score: ", 0
    player1ScoreTextLen equ ($ - player1ScoreText - 1)

    player2Score dd 0
    player2ScoreText db "Player 2 Score: ", 0
    player2ScoreTextLen equ ($ - player2ScoreText - 1)
section .text

_main:
    push ebp
    mov ebp, esp ; the prologue :sus

    call InitConsole

    call ClearConsole

    ; push COLOR_BLUE
    ; call SetConsoleColor

    ; push welcomeMessageLen
    ; push welcomeMessage
    ; call PrintStrLen

    ; push COLOR_WHITE
    ; call SetConsoleColor


    call GameMain

    push dword 10000
    call _Sleep@4

    mov eax, 0 ; make the return value for main be 0

    mov esp, ebp ; the epilogue
    pop ebp
    ret


GameMain:
    call InitPositions

    .game_loop:
        call ClearConsole

        inc word [counter]

        call PrintScore
        call PrintPlayers
        call PrintBall

        call ProcessInput
        
        call BallStep
        test eax, eax
        jnz .exit
        
        call SleepGame

        jmp .game_loop

    .exit:
        cmp eax, 1
        jne .inc_p2

        inc dword [player1Score]
        jmp .return

        .inc_p2:
        inc dword [player2Score]


        .return:
        call InitPositions
        jmp .game_loop


SleepGame:
    push dword [sleepTime]
    call _Sleep@4

    ret

InitPositions:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov ax, word [windowHeight] ; ax = windowHeight
    sub ax, playerHeight
    mov bx, 2 ; bx = 2
    xor dx, dx ; clear the upper 16 bits of the dividend (edx) before division
    div bx ; ax / bx oor windowHeight / 2
    ; add ax, 1


    movzx eax, ax
    shl eax, 16

    mov ax, 0

    ; CORD eax = {X: 0, y: center}
    mov [player1Pos], dword eax
    
    mov ax, [windowWidth]
    ; CORD eax = {x: windowWidth, y: center}

    mov [player2Pos], dword eax



    mov ax, word [windowWidth]
    sub ax, ballLen
    mov bx, 2
    xor dx, dx
    div bx

    mov [ballPos], dword eax

    mov esp, ebp
    pop ebp
    ret


BallStep:
    push ebp
    mov ebp, esp


    

    mov eax, [ballPos]


    push dword [ballYVelocity]
    push eax
    call AddYToCOORD

    mov dx, word [ballXVelocity]
    add ax, dx


    cmp ax, word [windowWidth]
    jge .hit_right

    cmp ax, 0
    jle .hit_left

    mov ebx, eax
    shr ebx, 16
    cmp bx, word [windowHeight]
    jge .hit_roof_or_floor

    cmp bx, 0
    jle .hit_roof_or_floor

    mov [ballPos], eax
    jmp .done

    .hit_roof_or_floor:
        neg word [ballYVelocity]
        jmp .done

    .hit_left:
        mov ecx, player1Pos  ; ecx = &player1Pos
        shr eax, 16 ; x -> y
        mov bx, word [ecx + 2] ;  player1Pos.Y
        
        cmp ax, bx
        jne .left.check_next

        .left.check_next:
        mov [tempVar], dword 0
            .left.loopy:
            cmp dword [tempVar], playerHeight
            jg .game_over_left

            mov cx, bx
            add cx, [tempVar]

            inc dword [tempVar]
            cmp ax, cx
            je .left.reverse_vel

            jmp .left.loopy

        .left.reverse_vel:
        neg word [ballXVelocity]
        jmp .done

    .hit_right:
        mov ecx, player2Pos  ; ecx = &player2Pos
        shr eax, 16 ; x -> y
        mov bx, word [ecx + 2] ;  player2Pos.Y
        
        cmp ax, bx
        jne .right.check_next

        .right.check_next:
        mov [tempVar], dword 0
            .right.loopy:
            cmp dword [tempVar], playerHeight
            jg .game_over_right

            mov cx, bx
            add cx, [tempVar]

            inc dword [tempVar]
            cmp ax, cx
            je .right.reverse_vel

            jmp .right.loopy

        .right.reverse_vel:
        neg word [ballXVelocity]
        jmp .done


    .done:
    xor eax, eax
    mov esp, ebp
    pop ebp
    ret

    .game_over_left:
    mov eax, 2

    jmp .return

    .game_over_right:
    mov eax, 1

    .return:
    mov esp, ebp
    pop ebp
    ret

PrintScore:
    push ebp
    mov ebp, esp

    push COLOR_BLUE
    call SetConsoleColor

    push dword 0
    push player1ScoreTextLen
    push player1ScoreText
    call PrintStrLenAtPos

    xor eax, eax
    add ax, player1ScoreTextLen


    push eax
    push dword [player1Score]
    call WriteDecPos

    xor eax, eax
    mov ax, word [windowWidth]
    sub ax, (player2ScoreTextLen + 2)

    push eax
    push player2ScoreTextLen
    push player2ScoreText
    call PrintStrLenAtPos

    mov ax, word [windowWidth]
    sub ax, 1
    push eax
    push dword [player2Score]
    call WriteDecPos

    push COLOR_WHITE
    call SetConsoleColor

    mov esp, ebp
    pop ebp
    ret

PrintBall:
    push ebp
    mov ebp, esp

    push dword [ballPos]
    push ballLen
    push ball
    call PrintStrLenAtPos

    mov esp, ebp
    pop ebp
    ret

PrintPlayers:
    push ebp
    mov ebp, esp ; the prologue :sus

    push dword [player1Pos]
    push playerLen
    push player
    call PrintStrLenAtPos

    mov ecx, 1
    .loop_1:
        cmp ecx, playerHeight
        jge .exit_1

        mov [tempVar], ecx ; :sob

        push dword ecx
        push dword [player1Pos]
        call AddYToCOORD

        push eax
        push playerLen
        push player
        call PrintStrLenAtPos
        
        mov ecx, [tempVar]
        
        inc ecx
        jmp .loop_1

    
    
    .exit_1:

    push dword [player2Pos]
    push playerLen
    push player
    call PrintStrLenAtPos

    mov ecx, 1
    .loop_2:
        cmp ecx, playerHeight
        jge .exit_2

        mov [tempVar], ecx ; :sob

        push dword ecx
        push dword [player2Pos]
        call AddYToCOORD
        mov ax, [windowWidth]

        push eax
        push playerLen
        push player
        call PrintStrLenAtPos
        
        mov ecx, [tempVar]
        
        inc ecx
        jmp .loop_2
    
    .exit_2:

    mov esp, ebp ; the epilogue
    pop ebp
    ret

ProcessInput:
    push ebp
    mov ebp, esp

    call GetLastKey

    cmp [isKeyDown], word TRUE
    jne .return
    cmp ax, VK_DOWN
    jne .is_vk_up
    
    mov eax, [player1Pos]
    shr eax, 16
    add ax, playerSpeed

    mov bx, ax
    add bx, playerHeight
    cmp bx, [windowHeight]
    jge .return

    shl eax, 16
    mov [player1Pos], eax


    .is_vk_up:
    cmp ax, VK_UP
    jne .is_w_down

    mov eax, [player1Pos]
    shr eax, 16
    sub ax, playerSpeed

    cmp ax, 0
    jl .return

    shl eax, 16
    mov [player1Pos], eax


    .is_w_down:
    cmp ax, VK_W
    jne .is_s_down

    mov eax, [player2Pos]
    shr eax, 16
    sub ax, playerSpeed

    cmp ax, 0
    jle .return

    shl eax, 16
    mov ax, [windowWidth]
    mov [player2Pos], eax


    .is_s_down:
    cmp ax, VK_S
    jne .return

    mov eax, [player2Pos]
    shr eax, 16
    
    mov bx, ax
    add bx, playerHeight
    cmp bx, [windowHeight]
    jge .return

    add ax, playerSpeed


    shl eax, 16
    mov ax, [windowWidth]
    mov [player2Pos], eax

    .return:
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
    cmp byte [eax+ebx], 0
    je _exit_strlen
    add ebx, 1
    jmp _loop

_exit_strlen:
    mov eax, ebx ; make return value equal the fuckinnn i or length of the string

    mov esp, ebp
    pop ebp
    ret


WriteDec: ; eax = integer to write
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

WriteDecPos:
    push ebp
    mov ebp, esp

    push dword [ebp+8] ; integer value
    push dword [ebp+12]  ; position
    push dword [hCurrentOut]
    call _SetConsoleCursorPosition@8
    test eax, eax
    jz Error

    pop eax
    call WriteDec

    mov esp, ebp
    pop ebp
    ret

SetConsoleColor: ; SetConsoleColor(int Color)
    push ebp
    mov ebp, esp ; the prologue :sus

    push dword [ebp+8]
    push dword [hCurrentOut]
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


; INPUT

GetKey:
    push ebp
    mov ebp, esp
    ; typedef struct _INPUT_RECORD {
    ; WORD  EventType; 0
    ; union { 2
    ;     KEY_EVENT_RECORD          KeyEvent; 24
    ;     MOUSE_EVENT_RECORD        MouseEvent; 16
    ;     WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent; 4
    ;     MENU_EVENT_RECORD         MenuEvent; 4
    ;     FOCUS_EVENT_RECORD        FocusEvent; 4
    ; } Event;
    ; } INPUT_RECORD; 26 (26 because we only take into account of the largest memeber of Event which is key event)

    ; typedef struct _KEY_EVENT_RECORD {
    ; BOOL  bKeyDown; 0
    ; WORD  wRepeatCount; 4
    ; WORD  wVirtualKeyCode; 6
    ; WORD  wVirtualScanCode; 8
    ; union { 10
    ;     WCHAR UnicodeChar; 12
    ;     CHAR  AsciiChar; 13
    ; } uChar; 13
    ; DWORD dwControlKeyState; 17
    ; } KEY_EVENT_RECORD; 17 (this is probably wrong XD)

    ; BOOL WINAPI ReadConsoleInput(
    ; _In_  HANDLE        hConsoleInput, 0
    ; _Out_ PINPUT_RECORD lpBuffer, 4
    ; _In_  DWORD         nLength, 8
    ; _Out_ LPDWORD       lpNumberOfEventsRead 12
    ; ); 16

    

    sub esp, 26 ; INPUT_RECORD
    
    lea eax, [esp-4] ; lpNumberOfThingosRead
    push eax

    push dword 1 ; nLength

    lea eax, [ebp-26]
    push eax ; lpBuffer

    push dword [hStdIn]

    call _ReadConsoleInputA@16
    test eax, eax
    jz Error

    cmp word [ebp-26], KEY_EVENT 
    jnz .return

    mov ax, word [ebp-16] ; 26 (INPUT_RECORD) - 2 (WORD EventType) - 6 (offset to wVirtualKeyCode) = 16
	shl eax, 16 
	cmp dword [ebp-24], 0 ;  26 (INPUT_RECORD) - 2 (WORD EventType) - 0 (offset to bKeyDown) = 24
	je .return
	mov ax, 1
    
    mov esp, ebp
    pop ebp
    ret


    .return:
        xor eax, eax
        mov esp, ebp
        pop ebp
        ret


GetKeyCount:
	sub esp, 4
	push esp ; lpNumberOfEventsRead
	push dword [hStdIn] ; hConsoleHandle
	call _GetNumberOfConsoleInputEvents@8
	test eax, eax
	jz Error
	mov eax, dword [esp]
	add esp, 4
	ret

GetLastKey:
    push ebp
    mov ebp, esp

    call GetKeyCount
	test eax, eax
	jz .return_no_key
    
    push ebx

	call GetKey
	test ax, ax
	jz .return_no_key
	shr eax, 16
    mov [isKeyDown], word TRUE
	mov word [lastKeyDown], ax
    
    pop ebx
    jmp .return



.return_no_key:
    mov [isKeyDown], word FALSE

.return:
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



; MATH SHEET

AddYToCOORD: ; AddYToCOORD(COORD cord, int value)
    push ebp
	mov ebp, esp



    mov ax, word [ebp+10] ; coord.Y
    add ax, [ebp+12] ; coord.Y + value

    shl eax,16
    mov ax, word [ebp+8]

    mov esp, ebp
    pop ebp
    ret