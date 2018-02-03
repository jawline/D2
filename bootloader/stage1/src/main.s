;We will be loaded to 0x7C00 by the BIOS
org 0x7C00

[bits 16]

jmp start

times 93 db 'F' ;Save some memory for the FAT master record

;After the FS information we load files/data and have entry point
%include "sizes.s"
%include "disk.s"
%include "help.s"

stage_1_msg db "Stage 1 Entry", 13, 10, 0
load_msg db "Loading...", 13, 10, 0
load_fail_msg db "Load Error", 13, 10, 0

start:

.load_segments:
    ;Clear initial state
    xor ax, ax
    mov ds, ax
    mov es, ax

.store_disk:
    mov [disk_num], dl

.set_video_mode:
    mov ah, 0
    mov al, 2
    int 0x10
    
    mov ah, 0x01
    mov cx, 0x0100
    int 0x10

    mov ah, 0x08
    int 0x10

    ;---
    ;- Load Stage 2
    ;---
    
.start_loading:

    mov si, stage_1_msg ;S1 msg
    call printstr

    ;Call the loading message
    mov si, load_msg
    call printstr

    call read_hdd
    
    ;Check if AF != 0 (success)
    and ah, ah
    jz .fail

    ;Send the disk_num with it
    mov ebp, [disk_num]

    jmp stage_2_location

.fail:
    mov si, load_fail_msg
    call printstr

;Pad to 512 bytes
times (stage_1_size - 2) - ($ - $$) db 0x00

;Some BIOS magic
dw 0xAA55
