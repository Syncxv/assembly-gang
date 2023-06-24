global _main
extern _printf

section .data
    bru db "result: %d", 10, 0


section .text

_main:
    push ebp
    mov ebp, esp ; the proluge :sus

    push 2
    push 10
    call _addx ; addx(10, 2)

    push eax
    push bru
    call _printf ; printf("result: %d", eax); eax is the return value from addx

    mov esp, ebp ; the epilouge
    pop ebp
    ret

_addx:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]  ; the first argument (value)
    mov ebx, [ebp+12] ; the second argument (x)

    add eax, ebx

    mov esp, ebp
    pop ebp
    ret
