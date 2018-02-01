;-----
;- 32 bit dummy GDT mapping 0x0 - max
;----

gdt_32:

.null: equ $ - gdt_32
    dq 0x0 ;Create a null descriptor

.code: equ $ - gdt_32
    dw 0xFFFF ;limit low
    dw 0 ;base low
    db 0 ;base middle
    db 10011010b ;Access
    db 11001111b
    db 0 ;base high      

.data: equ $ - gdt_32
    dw 0xFFFF ;limit low
    dw 0 ;base low
    db 0 ;base middle
    db 10010010b ;Access
    db 11001111b
    db 0 ;base high

.gdtr:
    dw $ - gdt_32 - 1 ;Limit
    dd gdt_32 ;Base

;----
;- 64 bit dummy GDT mapping 0x0 - max
;----

gdt_64:
 
.null: equ $ - gdt_64         ; The null descriptor.
    dw 0                         ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 0                         ; Access.
    db 0                         ; Granularity.
    db 0                         ; Base (high).

.code: equ $ - gdt_64         ; The code descriptor.
    dw 0                         ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 10011010b                 ; Access (exec/read).
    db 00100000b                 ; Granularity.
    db 0                         ; Base (high).

.data: equ $ - gdt_64         ; The data descriptor.
    dw 0                         ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 10010010b                 ; Access (read/write).
    db 00000000b                 ; Granularity.
    db 0                         ; Base (high).
    
.gdtr:                    ; The GDT-pointer.
    dw $ - gdt_64 - 1             ; Limit.
    dq gdt_64                     ; Base.
