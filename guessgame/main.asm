global _main
extern _printf
extern _scanf

section .data
    format db "%d", 0
    input resb 4 ; declaring a block of memory for our input from the user
    answer dd 9

section .text

_main:
    push promtmate
    call _printf

game_loop:
    push input
    push format
    call _scanf ; scanf("%d", &input)


    mov eax, dword [input]
    cmp eax, dword [answer] ; if *input == *answer (9)
    je _exit ; then go to exit label


    push dword [input]
    push dword dood
    call _printf ; printf("number: %d\nIS WRONG\n", *input)
    add esp, 8 ; restore stack :sus, (2 dwords = 8 bytes)


    jmp game_loop



_exit:
    push exiting
    call _printf

    mov eax, 1
    xor ebx, ebx
    int 0x80
section .data
    wrongnumer db "THAT IS WORNG", 10, 0
    promtmate db "enter a number between 0 and 10", 10, 0 ; 10 is \n (new line)
    dood db "number: %d", 10, "IS WRONG", 10, 0
    exiting db "CORRECT", 10, 0