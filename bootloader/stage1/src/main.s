; BIOS start location
org 0x7C00
bits 16

jmp start

%include "sizes.s"
%include "read.s"

times 93 db 'F' ;Save some memory for the FAT master record

stage_1_msg db "Stage 1 Entry", 13, 10, 0
load_msg db "Loading...", 13, 10, 0
is_floppy_msg db "Selected floppy disk", 13, 10, 0
is_hdd_msg db "Selected hdd", 13, 10, 0
load_fail_msg db "Load Error", 13, 10, 0
done_load db "Loaded, Jumping", 13, 10, 0

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
    cli ;Disable interrupts
    hlt ;Halt machine
    jmp hlt ;if we wake up redo

;Pad to 512 bytes
times (stage_1_size - 2) - ($ - $$) db 0x00

;Some BIOS magic
dw 0xAA55
