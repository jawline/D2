[bits 16]

;---
;- Loading variables
;---
read_mode db 0
disk_num db 0
current_retries db 0

select_ah:
    and dl, [disk_num]
    jz .floppy

.hdd:
    mov ah, 0x42
    ret

.floppy:
    mov ah, 0x2
    ret


read_hdd:

    ;Reset max retries
    mov byte [current_retries], max_retries

    ;Set buffer through AX register
    mov ax, 0x0000
    mov es, ax

    mov dl, [disk_num]
    call select_ah
    mov [read_mode], ah

.loop:

    ;Check if we have hit max retries
    dec byte [current_retries]
    jz .fail

    ;Load the disk number
    mov dl, [disk_num]
    mov ah, [read_mode]
    mov al, [reserved_sectors]

    ;Do the read
    mov dh, 0
    mov cl, 2
    mov ch, 0
    mov bx, stage_2_start

    int 0x13

    ;If the read failed try again
    jc .loop

    ;If sectors read != sectors asked try again
    cmp al, [reserved_sectors]
    jnz .loop 

    ;Return success AH=1
    mov ah, 1
    ret

.fail:
    mov ah, 0
    ret

