global _main
extern _printf

section .data
    bru db "length should be 24: %d", 10, 0


section .text

_main:
    push ebp
    mov ebp, esp ; the prologue :sus

    push bru
    call _strlen

    push eax
    push bru
    call _printf

    mov eax, 0 ; make the return value for main be 0

    mov esp, ebp ; the epilouge
    pop ebp
    ret

_strlen:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]  ; the first argument (str)
    mov ebx, 0        ; i =  0
_loop:
    cmp [eax+ebx], dword 0
    je _exit_strlen
    add ebx, 1
    jmp _loop

_exit_strlen:
    mov eax, ebx ; make return value equal the fuckinnn i or length of the string

    mov esp, ebp
    pop ebp
    ret
