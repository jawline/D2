[bits 64]
[GLOBAL halt]

;Optimized halt
halt:
    cli
    hlt
    jmp halt
