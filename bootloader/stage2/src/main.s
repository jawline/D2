
; BIOS start location
org 0x7E00

; we are targeting (x86) 16-bit real mode
bits 16

jmp start

stage_1_msg db "Stage 2 Starting", 13, 10, 0


start:

    ;Clear initial state
    xor ax, ax
    mov ds, ax
    mov es, ax

initial_video:
    
    mov ah, 0x01
    mov cx, 0x0100
    int 0x10

welcome_message:
    mov si, stage_1_msg
    call printstr
    jmp hlt

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

hlt:
    jmp hlt

;Pad to 4kb
times 4094 - ($ - $$) db 0x00

