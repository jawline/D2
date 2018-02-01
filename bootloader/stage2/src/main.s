; Stage 2 start
org 0x07E00

; We are always going to be entering in 16 bit real mode
[bits 16]
jmp start

%include 'src/gdt.s'
%include 'src/data.s'
%include 'src/real.s'
%include 'src/protected.s'
%include 'src/long.s'

;Pad to 4kb
times 4094 - ($ - $$) db 0x00
