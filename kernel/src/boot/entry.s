[bits 64]
[global start]
[extern rust_main]

start:
    mov rsp, 0xFFFF
    call rust_main
