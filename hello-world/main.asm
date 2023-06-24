global _main
extern _printf


section .text

_main:
    push 4
    push hello
    call _printf ; printf("hello mate %d", 4)
    mov eax, 0
    ret

hello:
    db "hello mate %d", 0