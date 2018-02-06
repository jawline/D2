[bits 64]
[global start]
[extern kernel_enter]

start:
    call kernel_enter
