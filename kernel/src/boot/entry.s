[bits 64]
[global start]
[extern kernel_enter]

start:
    mov rax, 0xDEADBAD
    call kernel_enter
