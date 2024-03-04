global _main
%include "../consoleutils/main.asm"

section .text

_main:
    call InitConsole
    call ClearConsole

    push word 50 ; x
    push word 2 ; y
    call SetCord

    push eax
    push 69
    call PrintDecPos

    xor eax, eax
    ret


SetCord: ; [ebp+8] = y, [ebp+10] = x
    push ebp
    mov ebp, esp

    mov ax, word [ebp+10]

    shl eax, 16
    mov ax, [ebp+8]

    ror eax, 16
    
    mov esp, ebp
    pop ebp
    ret