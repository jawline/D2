[bits 64]

[GLOBAL inb]
[GLOBAL outb]

inb: 
    xor rax, rax
    mov dx, di
    in al, dx
    ret

outb:
    mov ax, si
    mov dx, di
    out dx, al
    ret

outw:
    mov ax, si
    mov dx, di
    out dx, ax
    ret

inw:
    xor rax, rax
    mov dx, di
    in ax, dx
    ret
