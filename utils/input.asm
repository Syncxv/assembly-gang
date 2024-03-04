extern _ReadConsoleInputA@16
extern _GetNumberOfConsoleInputEvents@8

section .data
    KEY_EVENT equ 0x0001

    lastKeyDown dw 0
    isKeyDown dw 0


section .text
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

    push ebp
    mov ebp, esp

	sub esp, 4
	push esp ; lpNumberOfEventsRead
	push dword [hStdIn] ; hConsoleHandle
	call _GetNumberOfConsoleInputEvents@8
	; test eax, eax
	; jz Error
	mov eax, dword [esp]
	add esp, 4

    mov esp, ebp
    pop ebp
	ret


GetLastKey:
    push ebp
    mov ebp, esp

    call GetKeyCount
	test eax, eax
	jz .return_no_key
    
    ; push ebx

	call GetKey
	test ax, ax
	jz .return_no_key
	shr eax, 16
    mov [isKeyDown], word TRUE
	mov word [lastKeyDown], ax
    
    ; pop ebx
    jmp .return



.return_no_key:
    mov [isKeyDown], word FALSE

.return:
	mov esp, ebp
    pop ebp
    ret