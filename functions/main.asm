global _main
extern _printf


section .text

_main:
    call getnum
    push eax
    push hello
    call _printf ; printf("hello mate %d", 4)
    mov eax, 0
    ret


getnum:
    mov eax, 20
    ret

hello:
    db "hello mate %d", 0