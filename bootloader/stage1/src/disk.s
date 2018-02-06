[bits 16]

;---
;- Loading variables
;---

disk_num db 0

lba_packet:
	db	0x10                        ; Size of packet
	db	0                           ; Always 0 (OSDEV)
    sector_count    dw	0           ; number of sectors to read
    lower_address	dw	0x7E00		; memory buffer destination address (0:7c00)
	higher_address  dw	0		    ; in memory page zero
    lba_lower	    dd	1		    ; put the lba to read in this spot
	lba_higher      dd	0		    ; more storage bytes only for big lba's ( > 4 bytes )

;---
;- Read from LBA drive at [disk_num]
;---
read_hdd: 

    ;Set num sectors
    mov ax, [reserved_sectors]
    mov word [sector_count], ax

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
