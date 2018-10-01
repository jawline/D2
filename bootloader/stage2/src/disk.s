[bits 64]

;-----
;- Tool to read the kernel from disk
;----

kernel_start_location dw 0
kernel_end_location dw 0

disk_num dw 0

load_kernel:

    .loop:
        jmp .loop

    ret
