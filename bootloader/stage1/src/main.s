; BIOS start location
org 0x7C00
bits 16

jmp start

times 62 db 'F'

stage_1_msg db "Stage 1 Entry", 13, 10, 0
load_msg db "Loading...", 13, 10, 0
is_floppy_msg db "Selected floppy disk", 13, 10, 0
is_hdd_msg db "Selected hdd", 13, 10, 0
load_fail_msg db "Load Error", 13, 10, 0
done_load db "Loaded, Jumping", 13, 10, 0

max_retries db 10

disk_num db 0
current_retries db 0
num_sectors db 8

read_mode db 0

start:

    ;Clear initial state
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov [disk_num], dl ;Store initial disk number
    
    ;Video setup
    mov ah, 0
    mov al, 2
    int 0x10
    
    mov ah, 0x01
    mov cx, 0x0100
    int 0x10

    mov ah, 0x08
    int 0x10

    mov si, stage_1_msg ;S1 msg
    call printstr

    ;---
    ;- Load Stage 2
    ;---

    ;Call the loading message
    mov si, load_msg
    call printstr

    call read_hdd
    
    ;Check if AH=1 (success)
    and ah, ah
    jz load_fail

    mov si, done_load
    call printstr
    jmp 0x7E00

load_fail:
    mov si, load_fail_msg
    call printstr

hlt:
    jmp hlt


;----
;- Help functions
;----

select_ah:
    and dl, [disk_num]
    jz select_ah_floppy

select_ah_hdd:
    mov si, is_hdd_msg
    call printstr
    mov ah, 0x42
    ret

select_ah_floppy:
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

printstr:
   cld                    ; clear df flag - lodsb increments si
printstr_loop:
   lodsb                  ; load next character into al, increment si
   or al, al              ; sets zf if al is 0x00
   jz printstr_end
   mov ah, 0x0E           ; teletype output (int 0x10)
   int 0x10               ; print character
   jmp printstr_loop
printstr_end:
   ret                    ; return to caller address

;Pad to 512 bytes
times 510 - ($ - $$) db 0x00

;Some BIOS magic
dw 0xAA55
