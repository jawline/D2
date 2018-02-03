;-----
;- Tool to read the kernel from disk
;----

%define volume_offset 43
%define oem_offset 3
%define oem_identifier boot_location + oem_offset
%define volume_name boot_location + volume_offset


%define max_retries 10

disk_msg db "Loading from disk: ", 0
space db " ", 0
newline_16 db 13, 10, 0

load_kernel:

    mov si, disk_msg
    call print_str_16

    mov si, volume_name
    call print_str_16

    mov si, space
    call print_str_16

    mov si, oem_identifier
    call print_str_16

    mov si, newline_16
    call print_str_16

jmp $
    ret

;---
;- Loading variables
;---
read_mode db 0
disk_num db 0
current_retries db 0
num_sectors db 0
target_location dd 0

select_ah:
    and dl, [disk_num]
    jz .floppy

.hdd:
    mov ah, 0x42
    ret

.floppy:
    mov ah, 0x2
    ret


read_from_disk:

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
    mov al, [num_sectors]

    ;Do the read
    mov dh, 0
    mov cl, 2
    mov ch, 0
    mov bx, [target_location]

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

