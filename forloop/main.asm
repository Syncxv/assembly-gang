global _main
extern _printf


section .text

_main:

    mov ecx, 0 ; i = 0;
    mov edx, 0 ; count = 0;


loopy:
    cmp ecx, 10
    jge last ; if (i >= 10) jump to last
    add edx, ecx ; count = count + i
    add ecx, 1 ; i = i + 1
    jmp loopy


last:
    push edx
    push hello
    call _printf ; printf("hello mate %d", count)
    mov eax, 0
    ret

hello:
    db "hello mate %d", 0