global _main

%include "../utils/console.asm"

section .data
    testy db "hello mateyy", 10, 0
    addxthingy db "addx: %d", 10, 0

section .text

_main:
    ; push 4
    ; push 2
    ; call addx
    
    call InitConsole
    call ClearConsole
    xor eax, eax
    mov ax, [windowWidth]
    mov bx, 2
    xor dx, dx
    div bx

    shl eax, 16
    mov ax, [windowHeight]

    ror eax, 16

    push eax
    push testy
    call PrintStrAtPos



    xor eax, eax
    ret
