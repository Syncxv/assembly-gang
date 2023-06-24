global _main
extern _printf


section .text

_main:
    call getnum
    push eax
    push hello
    call _printf ; printf("hello mate %d", getnum())
    mov eax, 0
    ret

; int getnum()
;   return 20
getnum:
    mov eax, 20 ; eax = 20
    mov ebx, 2  ; ebx = 2
    mul ebx     ; eax *= ebx
    ret         ; return eax

hello:
    db "hello mate %d", 0