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

next_sector_msg db "Next Sector", 13, 10, 0
done_file_msg db "Done With File", 13, 10, 0

lag_msg db "LAG.", 13, 10, 0

fat_1_location dw 0

kernel_start_location dw 0
kernel_end_location dw 0

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
    mov word [sector_count], ax
  
    ;Calculate the start sector
    mov word dx, [reserved_sectors]
    add dx, 1
    mov word [lba_lower], dx

    ;Load into the memory just after stage2
    mov word [lower_address], $$ + stage_2_size
    mov word [fat_1_location], $$ + stage_2_size

    push word [lba_lower]
    call read_from_disk     
    pop word [lba_lower]

    or ah, ah
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
    push ax

    ;[start_sector] = AX + [start_sector]
    ;TODO: Start sector is a byte because we don't roll it over
    mov word dx, [lba_lower]
    add ax, dx
    mov word [lba_lower], ax

    ;Restore AX (AX = sectors_per_fat * total_fats)
    pop ax

    ;AX = sector_size * (sectors_per_fat * total_fats)
    mov dx, sector_size
    mul dx

    ;Add this new size to the target location
    mov word dx, [lower_address]
    add dx, ax
    mov [lower_address], dx

    ;Calculate the directory size from the number of entries
    mov word ax, [root_dir_entries]

    ;AX = [root_dir_entries] * bytes_per_dir_entry
    mov bx, bytes_per_dir_entry
    mul bx
    
    ;AX = ([root_dir_entries] * bytes_per_dir_entry) / sector_size
    mov bx, sector_size
    xor edx, edx
    div bx
    mov word [sector_count], ax

    ;Load the root directory
    push word [sector_count]
    call read_from_disk
    pop word [sector_count]    

    or ah, ah
    jz .fail
    

    mov si, ld_dir_msg
    call print_str_16

    mov si, disk_msg
    call print_str_16
   
    ;Set DX = root directory location
    mov dx, [lower_address]

    ;Calculate the end of the root directory
    mov ax, sector_size
    mul byte [sector_count] ;AX = sector_size * num_sectors in last read
    add ax, dx
    mov si, ax
    
    call find_kernel

    or ax, ax
    jz .fail

    ;Get the first cluster ID from the entry 
    mov bx, dx
    add bx, directory_entry_cluster_offset
    mov bx, [bx]

    ;SI = the fat1 in memory
    mov si, [fat_1_location]

    ;DI = [start_sector] + [num_sectors] because end of last read is start of data sector
    xor ax, ax
    mov word ax, [lba_lower]
    add word ax, [sector_count]
    mov di, ax

    ;Change the ES segment for the kernel location
    mov word [target_location], 0x0
    mov ax, 0x1000
    mov es, ax

    ;Load the kernel target location
    ;mov word [target_location], 0
    call load_file

    ;Reset the ES now the kernel is in memory
    mov ax, 0
    mov es, ax

    mov si, lag_msg
    call print_str_16

    mov ax, 1
    ret

.fail:
    mov si, bad_read_msg
    call print_str_16
    mov ax, 0
    ret

;---
;- Loops through all entries in root directory (DX) and sets DX = to the kernel entry or panic if it doesn't exist
;- Expects SI to be the end of the end of the root directory in memory
;---

find_kernel:

    ;TODO: This will crash if there is no kernel on the disk
    ;Make it print a good error message instead

.loop:    

    push si
    
    ;Test the current entry against our desired filename
    mov si, kernel_filename
    mov di, dx
    call strcmp_8_16

    pop si 
  
    ;Check if the result is 0
    or ax, ax
    jz .exit
    
    ;If not move to the next entry
    add dx, bytes_per_dir_entry

    ;Bounds check on the size of the root directory
    cmp dx, si
    jae .fail

    jmp .loop

.fail:
    mov ax, 0
    ret
.exit:
    mov ax, 1
    ret

;---
;- Load a file starting at cluster BX to [target_location] using the FAT stored in SI and a data sector starting DI
;---

;Take cluster address AX to memory address BX
resolve_cluster:

    mov dl, 2
    mul dl

    add ax, si

    ret
    

;Take AX as cluster and return AX as sector on disk
cluster_to_sector:

    mov byte cl, [sectors_per_cluster]  
    mul cl
    add ax, di

    ret

;Find the address of the next sector
next_sector:

    ;Load the address of the next cluster into BX
    mov ax, bx
    call resolve_cluster
    mov bx, ax

    ;Dereference ax = [next_cluster_address]
    mov word ax, [bx]

    ;See if AX >= 0xFFF7
    cmp ax, 0xFFF7
    jae .end_of_file

    mov bx, ax

    ret

.end_of_file:
    mov bx, 0
    ret

load_file:

.loop:

    push si
    mov si, next_sector_msg
    call print_str_16
    pop si

    ;Decide the sector from the cluster
    mov ax, bx
    call cluster_to_sector

    ;Save cluster ID for read
    push bx

    ;Do the read from what we have worked out
    mov byte [start_sector], al

    ;Set num_sectors to sectors_per_cluster
    mov byte al, [sectors_per_cluster]
    mov byte [num_sectors], al

    call read_from_disk
    add word [target_location], sector_size ;Increment the target location

    ;Get cluster ID back
    pop bx

    or ah, ah
    jz .fail

    ;Prepare the next sector in the cluster
    call next_sector
    or bx, bx
    jz .done_loading    

    jmp .loop

.done_loading:

    mov si, done_file_msg
    call print_str_16

    ret

.fail:
    mov si, bad_read_msg
    call print_str_16
    jmp $ ;TODO: Do we really want to halt here?

;---
;- Loading variables
;---

disk_num db 0

lba_packet:
	db	0x10                        ; Size of packet
	db	0                           ; Always 0 (OSDEV)
    sector_count    dw	0           ; number of sectors to read
    lower_address	dw	0    		; memory buffer destination address (0:7c00)
	higher_address  dw	0		    ; in memory page zero
    lba_lower	    dd	1		    ; put the lba to read in this spot
	lba_higher      dd	0		    ; more storage bytes only for big lba's ( > 4 bytes )

;---
;- Read from LBA drive at [disk_num]
;---

read_from_disk: 

	mov si, lba_packet
	mov ah, 0x42 ;LBA read mode
    
  	mov dl, [disk_num] ;Set DL disk_num supplied by bios

    ;Execute read
	int 0x13
	jc short .fail
    
    mov ah, 1
    ret

.fail:
    mov ah, 0
    ret
