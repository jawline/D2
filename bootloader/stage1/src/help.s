[bits 16]

;----
;- Stage 1 helper functions
;----

hlt:
    cli ;Disable interrupts
    hlt ;Halt machine
    jmp hlt ;if we wake up redo

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
