global _main
extern _printf
extern addx
extern PrintString
extern InitConsole 

section .data
    testy db "hello mate", 0

section .text

_main:
    push 4
    push 2
    call addx

    call InitConsole

    push testy
    call PrintString ; PrintString("hello mate")
    
    mov eax, 0
    ret
