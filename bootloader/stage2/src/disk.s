;-----
;- Tool to read the kernel from disk
;----

;Offsets into  the FAT record stored within the boot sector
%define oem_identifier boot_location + 3
%define volume_name boot_location + 43
%define reserved_sectors boot_location + 13
%define sectors_per_fat boot_location + 22
%define total_fats boot_location + 16
%define root_dir_entries boot_location + 17

%define max_retries 10

disk_msg db "Loading from disk: ", 0
space db " ", 0
newline_16 db 13, 10, 0
bad_read_msg db "Bad Read", 13, 10, 0

ld_fat_msg db "Loaded FAT1", 13, 10, 0
ld_dir_msg db "Loaded Root Directory", 13, 10, 0

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

    ;---
    ;- Load FAT1 (The first FAT table on the disk)
    ;---

    ;Calculate the number of sectos
    mov word ax, [sectors_per_fat]
    mov word [num_sectors], ax
  
    ;Calculate the start sector
    mov word dx, [reserved_sectors]
    add dx, 1
    mov word [start_sector], dx

    mov word [target_location], $$ + stage_2_size
    call read_from_disk     

    and ah, ah
    jz .fail

    mov si, ld_fat_msg
    call print_str_16

    ;---
    ;- Load Root Directory
    ;---

    ;Work out where in memory it should go

    ;Multiply the size of a sector by the number of sectors in a FAT
    mov word ax, 1
    mov word dx, [sectors_per_fat]
    mul dx

    ;Multiply that by the number of fats
    mov byte dx, [total_fats]
    mul dx

    mov word dx, [start_sector]
    add ax, dx
    mov word [start_sector], dx

    ;Add this new size to the target location
    mov word dx, [target_location]
    add dx, ax
    mov [target_location], dx

    ;Calculate the directory size from the number of entries
    mov word ax, [root_dir_entries]
    mov dx, 32
    mul dx
    mov dx, sector_size
    div dx
    mov [num_sectors], ax

    call read_from_disk
    and ah, ah
    jz .fail

    mov si, ld_dir_msg
    call print_str_16


    mov ah, 1
    ret

.fail:
    mov si, bad_read_msg
    call print_str_16
    mov ah, 0
    ret

jmp $
    ret

;---
;- Loading variables
;---
start_sector db 0
read_mode db 0
disk_num db 0
current_retries db 0
num_sectors db 0
target_location dw 0

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
    mov cl, [start_sector]
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

