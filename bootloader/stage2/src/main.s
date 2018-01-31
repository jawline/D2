
; Stage 2 start
org 0x07E00

; we are targeting (x86) 16-bit real mode
bits 16

jmp start

stage_msg db "Stage 2 Starting", 13, 10, 0
enable_a20_msg db "Enable A20", 13, 10, 0
gdt_msg db "GDT", 13, 10, 0
done_msg db "Done", 13, 10, 0

start:

    ;Clear initial state
    xor ax, ax
    mov ds, ax
    mov es, ax

    ;Clear screen
    mov al, 2
    mov ah, 0
    int 0x10

    ;Say hello
    mov si, stage_msg
    call printstr

    ;Get ready for magical kernel land
    call enable_a20
    call load_gdt
hlt:
    jmp hlt

;----
;- Enable A20
;----

enable_a20:

    ;Print A20 msg
    mov si, enable_a20_msg
    call printstr
    
    ;We support only the fast A20 gate

    ;Check if already enabled
    in al, 0x92
    test al, 2
    jnz enable_a20_already

    ;Use the fast switch
    or al, 2
    and al, 0xFE
    out 0x92, al

enable_a20_already:

    ;Print success
    mov si, done_msg
    call printstr
    ret

;----
;- GDT
;----

gdt_start:
    gdt_size dw 0x7
    null_limit dw 0x0
    null_base dw 0x0
    null_flags dd 0x0

load_gdt:
    mov si, gdt_msg
    call printstr

    ;Load our dummy GDT
    lgdt [gdt_start]

    ret

;-----
;- Helper methods
;-----

printstr:
   cld                    ; clear df flag - lodsb increments si
printstr_loop:
   lodsb                  ; load next character into al, increment si
   or al, al              ; sets zf if al is 0x00
   jz printstr_end
   mov ah, 0x0E           ; teletype output (int 0x10)
   int 0x10               ; print character
   jmp printstr_loop
printstr_end:
   ret                    ; return to caller address


;Pad to 4kb
times 4094 - ($ - $$) db 0x00
