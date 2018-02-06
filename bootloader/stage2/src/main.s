; Stage 2 start
org 0x07E00

; We are always going to be entering in 16 bit real mode
[bits 16]
jmp start

%include 'sizes.s'
%include 'gdt.s'
%include 'data.s'
%include 'disk.s'
%include 'real.s'
%include 'protected.s'
%include 'long.s'

;Pad to 4kb
times stage_2_size - ($ - $$) db 0x00
