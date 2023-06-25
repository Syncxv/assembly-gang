global _main
extern _printf

section .data
    my_array resd 10 ; 40 bytes of memory
    bru db "%d", 10, 0


section .text

_main:
    push ebp
    mov ebp, esp ; the prologue :sus

    mov ecx, 0
    mov ebx, 0
_init_loop:
    cmp ecx, 10
    je _exit_init_loop

    mov eax, ecx
    mov edx, 4
    mul edx ; eax *= ebx (byte_index = index * 4)

    mov [my_array+eax], ecx ; my_array[byte_index] = index
    add ecx, 1

    jmp _init_loop
_exit_init_loop:

    mov eax, 0
_print_loop:
    cmp eax, 40
    je _exit
    
    push eax ; to save eax value. printf does some stuff with it and changes it :raised

    push dword [my_array+eax]
    push bru
    call _printf ; printf("%d\n", my_array[byte_index]) (or eax)
    add esp, 8 ; restore stack (free the 8 bytes from the stack)

    pop eax ; restore eax to original eax

    add eax, 4 ; eax += 4

    jmp _print_loop


_exit:
    mov eax, 0 ; make the return value for main be 0

    mov esp, ebp ; the epilogue
    pop ebp
    ret


