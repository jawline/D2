
; BIOS start location
org 0x7C00

; we are targeting (x86) 16-bit real mode
bits 16

jmp start

start:

    ;Clear initial state
    xor ax, ax
    mov ds, ax
    mov es, ax

;;;;;;;;;;;
; Padding ;
;;;;;;;;;;;
; $ is the address of the current line, $$ is the base address for
; this program.
; the expression is expanded to 510 - ($ - 0x7C00), or
; 510 + 0x7C00 - $, which is, in other words, the number of bytes
; before the address 510 + 0x7C00 (= 0x7DFD), where the 0xAA55
; signature shall be put.
times 510 - ($ - $$) db 0x00

;;;;;;;;;;;;;;;;;;
; BIOS signature ;
;;;;;;;;;;;;;;;;;;
dw 0xAA55
