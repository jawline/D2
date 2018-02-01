;---
;- General data
;---

done_msg db "Done", 13, 10, 0

;---
;- Data for 16 bit segment
;---

stage_msg db "Stage 2 Starting", 13, 10, 0
enable_a20_msg db "Enable A20", 13, 10, 0
segments_msg db "Reloading Segments", 13, 10, 0
gdt_msg db "GDT", 13, 10, 0

;---
;- Data for 32 bit segment
;---

empty_screen:
    times (80 * 25) db ' '
    db 0

protected_msg: db 'Entered Protected Mode', 0
error_nolong_msg db "Error: No Long Mode", 0
longmode_supported_msg db "Machine is 64bit",  0
paging_enabled_msg db "Paging Enabled", 0
