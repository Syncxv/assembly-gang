global _main
%include "../consoleutils/main.asm"

section .text

_main:
    call InitConsole
    call ClearConsole

    mov eax, 69420
    call PrintDec

    xor eax, eax
    ret