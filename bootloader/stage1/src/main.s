
; BIOS start location
org 0x7C00
bits 16

jmp start

stage_1_msg db "Stage 1 Entry", 13, 10, 0
load_msg db "Loading...", 13, 10, 0
is_floppy_msg db "Load from floppy", 13, 10, 0
is_hdd_msg db "Load from hd", 13, 10, 0
load_fail_msg db "Load Error", 13, 10, 0

disk_num db 0

start:

    ;Clear initial state
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov [disk_num], dl ;Store initial disk number
    
    ;Video setup    
    mov ah, 0x01
    mov cx, 0x0100
    int 0x10

    mov ah, 0x08
    int 0x10

    mov si, stage_1_msg ;S1 msg
    call printstr



hdd:
    ;Call the loading message
    mov si, load_msg
    call printstr

    mov al, 1

    mov ax, 0x7E00
    mov es, ax

    mov ax, 0x8600
    mov bx, ax

    call read_hdd

check_result:
    jc load_fail
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

    ;Select floppy or HDD
    mov dl, [disk_num]
    call select_ah

    ;Load the disk number
    mov dl, [disk_num]

    mov cl, 1
    mov ch, 0
    int 0x13
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
