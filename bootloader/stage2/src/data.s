;---
;- Scratch space
;---

scratch_msg: times 20 db 0x0

;---
;- Disk info
;---

disk_num db 0

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

;---
;- Data for 64 bit segment
;---

in_long_mode db "Entered Long Mode", 0
loading_kernel db "Loading Kernel...", 0
load_fat_1_msg db "Loading FAT1", 0
load_root_dir_msg db "Loading Root Directory", 0
search_kernel_record_msg db "Searching for Kernel Record", 0
loaded_msg db "Loaded.", 0
cant_find_kernel_msg db "Cannot Find Kernel.", 0
load_file_msg db "Loading file.", 0
step_msg db "Step.", 0
space_msg db " ", 0

kernel_name db "kernel", 0
kernel_name_len db 6
