; Stage 2 start
org 0x07E00

; We are always going to be entering in 16 bit real mode
[bits 16]
jmp start

stage_msg db "Stage 2 Starting", 13, 10, 0
enable_a20_msg db "Enable A20", 13, 10, 0
segments_msg db "Reloading Segments", 13, 10, 0
gdt_msg db "GDT", 13, 10, 0
done_msg db "Done", 13, 10, 0
error_nolong_msg db "Error: No Long Mode", 13, 10, 0
longmode_supported_msg db "Machine is 64bit", 13, 10, 0

%include 'src/real.s'
%include 'src/protected.s'

;Pad to 4kb
times 4094 - ($ - $$) db 0x00
