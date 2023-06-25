global _main
extern _printf
extern _GetProcessHeap@0

section .data
    dbg db "thing: %d", 10, 0

section .text

_main:
    push ebp
    mov ebp, esp ; the prologue :sus

    call _GetProcessHeap@0

    push eax
    push dbg
    call _printf

    mov eax, 0 ; make the return value for main be 0

    mov esp, ebp ; the epilogue
    pop ebp
    ret


