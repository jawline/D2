[bits 64]

;-----
;- Tool to read the kernel from disk
;----

disk_msg db "Loading from disk: ", 0
space db " ", 0
newline_16 db 13, 10, 0
bad_read_msg db "Bad Read", 13, 10, 0

kernel_filename db "kernel  ", 0

ld_fat_msg db "Loaded FAT1", 13, 10, 0
ld_dir_msg db "Loaded Root Directory", 13, 10, 0

done_file_msg db "Done With File", 13, 10, 0

lag_msg db "LAG.", 13, 10, 0

fat_1_location dw 0

kernel_start_location dw 0
kernel_end_location dw 0

disk_num dw 0

load_kernel:

    .loop:
        jmp .loop

    ret
