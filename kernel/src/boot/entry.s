[bits 64]
[global start]
[extern kernel_enter]

start:
    mov rsp, 0xFFFF
    call kernel_enter
