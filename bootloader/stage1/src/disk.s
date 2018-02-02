[bits 16]

%define max_retries 10
%define read_mode 0

disk_num db 0
current_retries db 0
num_sectors db (stage_2_size / sector_size)

select_ah:
    and dl, [disk_num]
    jz .floppy

.hdd:
    mov si, is_hdd_msg
    call printstr
    mov ah, 0x42
    ret

.floppy
    mov si, is_floppy_msg
    call printstr
    mov ah, 0x2
    ret


read_hdd:

    ;Reset max retries
    mov ah, [max_retries]
    mov [current_retries], ah

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
    mov al, [num_sectors]

    ;Do the read
    mov dh, 0
    mov cl, 2
    mov ch, 0
    mov bx, 0x7E00

    int 0x13

    ;If the read failed try again
    jc .loop

    ;If sectors read != sectors asked try again
    cmp al, [num_sectors]
    jnz .loop 

    ;Return success AH=1
    mov ah, 1
    ret

.fail:
    mov ah, 0
    ret

