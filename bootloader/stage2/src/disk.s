;-----
;- Tool to read the kernel from disk
;----

;Offsets into  the FAT record stored within the boot sector
%define oem_identifier boot_location + 3
%define volume_name boot_location + 43
%define reserved_sectors boot_location + 14
%define sectors_per_fat boot_location + 22
%define total_fats boot_location + 16
%define root_dir_entries boot_location + 17
%define sectors_per_cluster boot_location + 13

%define directory_entry_cluster_offset 26
%define bytes_per_dir_entry 32
%define max_retries 10

disk_msg db "Loading from disk: ", 0
space db " ", 0
newline_16 db 13, 10, 0
bad_read_msg db "Bad Read", 13, 10, 0

kernel_filename db "kernel", 0

ld_fat_msg db "Loaded FAT1", 13, 10, 0
ld_dir_msg db "Loaded Root Directory", 13, 10, 0

next_sector_msg db "Next Sector", 13, 10, 0
done_file_msg db "Done With File", 13, 10, 0

fat_1_location dw 0

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
    mov byte [start_sector], dl

    ;Load into the memory just after stage2
    mov word [target_location], $$ + stage_2_size
    mov word [fat_1_location], $$ + stage_2_size

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
    mov word ax, [sectors_per_fat] 

    ;AX = sectors_per_fat

    ;Multiply that by the number of fats
    mov byte dl, [total_fats]
    mul dl

    ;AX = sectors_per_fat * total_fats
    mov bx, ax ;Store while we do start sector

    ;[start_sector] = AX + [start_sector]
    ;TODO: Start sector is a byte because we don't roll it over
    mov byte dl, [start_sector]
    add al, dl
    mov byte [start_sector], al

    ;Restore AX (AX = sectors_per_fat * total_fats)
    mov ax, bx

    ;AX = sector_size * (sectors_per_fat * total_fats)
    mov dx, sector_size
    mul dx

    ;Add this new size to the target location
    mov word dx, [target_location]
    add dx, ax
    mov [target_location], dx

    ;Calculate the directory size from the number of entries
    mov word ax, [root_dir_entries]

    ;AX = [root_dir_entries] * bytes_per_dir_entry
    mov bx, bytes_per_dir_entry
    mul bx
    
    ;AX = ([root_dir_entries] * bytes_per_dir_entry) / sector_size
    mov bx, sector_size
    xor edx, edx
    div bx
    mov [num_sectors], ax

    call read_from_disk
    and ah, ah
    jz .fail

    mov si, ld_dir_msg
    call print_str_16

    mov si, disk_msg
    call print_str_16
   
    mov dx, [target_location]
    call find_kernel

    mov si, dx
    call print_str_16

    mov si, newline_16
    call print_str_16

    ;Get the first cluster ID from he entry 
    mov bx, dx
    add bx, directory_entry_cluster_offset
    mov bx, [bx]

    ;SI = the fat1 in memory
    mov si, [fat_1_location]

    ;DI = [start_sector] + [num_sectors] because end of last read is start of data sector
    mov di, [start_sector]
    add di, [num_sectors]

    call load_file

    jmp $

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
;- Loops through all entries in root directory (DX) and sts DX = to the kernel entry or panic if it doesn't exist
;---

find_kernel:

    ;TODO: This will crash if there is no kernel on the disk
    ;Make it print a good error message instead

.loop:    
    
    ;Test the current entry against our desired filename
    mov si, kernel_filename
    mov di, dx
    
    call strcmp_16
    
    ;Check if the result is 0
    xor ax, ax
    jz .exit
    
    ;If not move to the next entry
    add dx, bytes_per_dir_entry 
    jmp .loop

.exit:
    ret

;---
;- Load a file starting at cluster BX to [target_location] using the FAT stored in SI and a data sector starting DI
;---

;Take cluster address AX to memory address BX
resolve_cluster:

    mov dl, 2
    mul dl

    add ax, si
    mov bx, ax
    ret
    

;Take AX as cluster and return AX as sector on disk
cluster_to_sector:

    mov byte cl, [sectors_per_cluster]  
    mul cl
    add ax, di

    ret

;Find the address of the next sector
next_sector:
    mov word ax, [bx]

    ;Save the cluster ID in bx
    mov cx, ax

    ;See if AX >= 0xFFF7
    cmp ax, 0xFFF7
    jae .end_of_file

    ;Store the cluster ID to AX
    mov ax, cx

    call resolve_cluster

    ret

.end_of_file:
    mov bx, 0
    ret

load_file:

    ;Find the start of the cluster in memory
    mov ax, bx
    call resolve_cluster    

.loop:

    push si
    mov si, next_sector_msg
    call print_str_16
    pop si

    ;Load the sector
    mov ax, bx
    call cluster_to_sector

    ;Prepare the next sector in the cluster
    call next_sector
    or bx, bx
    jz .done_loading    

    jmp .loop

.done_loading:

    mov si, done_file_msg
    call print_str_16

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

