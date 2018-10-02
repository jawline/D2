[bits 64]

long_entry:
    cli                           ; Clear the interrupt flag.

    ;Update the stack register
    mov ax, gdt_64.data           ; Set the A-register to the data descriptor.
    mov ds, ax                    ; Set the data segment to the A-register.
    mov es, ax                    ; Set the extra segment to the A-register.
    mov fs, ax                    ; Set the F-segment to the A-register.
    mov gs, ax                    ; Set the G-segment to the A-register.
    mov ss, ax                    ; Set the stack segment to the A-register.

    jmp .cnt
.cnt:

    mov edx, in_long_mode
    call print_str_64

    call load_kernel

    ;Load the SMAP adress into DI for the kernel
    mov di, $$ + stage_2_size
    jmp kernel_target_addr


;----
;- Load fat 1
;- @param rdi target destination for FAT1
;----

load_fat_1:

    mov edx, load_fat_1_msg
    call print_str_64

    xor eax, eax ;Clear EAX
    mov word ax, [reserved_sectors]
    mov cl, [sectors_per_fat]
    call ata_lba_read

    mov edx, loaded_msg
    call print_str_64

    ret

;----
;- Load root directory
;- @param rdi - target destination for root directory

load_root_dir:

    push rax
    push rbx
    push rcx
    push rdx

    mov edx, load_root_dir_msg
    call print_str_64

    ;Calculate CL=size of root directory in sectors
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx

    mov word ax, [root_dir_entries]

    mov word bx, bytes_per_dir_entry ;AX *= bytes_per_dir_entry
    mul ebx

    mov word bx, sector_size ;AX /= sector_size
    div ebx

    mov cl, al

    ;Calculate the start of the root directory
    xor rax, rax
    mov word ax, [sectors_per_fat] 
    mov byte bl, [total_fats]
    mul bx

    xor ebx, ebx
    mov word bx, [reserved_sectors]
    add eax, ebx

    call ata_lba_read

    mov edx, loaded_msg
    call print_str_64

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

;----
;- Load the kernel
;----

load_kernel:

    mov edx, loading_kernel
    call print_str_64

    mov rdi, 0x10000

    call load_fat_1
    call load_root_dir

.loop:
    jmp .loop

    ret


;----
;- Read from disk
;- @param rax - Logical (block) address to read
;- @param rbx - Number of sectors to read
;- @param rdi - The address to put memory to
;- On exit RDI will point to the end of the load
;----

read_from_disk:

    push rax
    push rbx
    push rcx
    push rdx

.loop:

    ;Read the maximum number of sectors
    mov cl, 0xFF

    ;If rbx < 0xFF then read rbx sectors instead
    cmp rbx, 0xFF
    jge .continue

    mov cl, bl

.continue:

    call ata_lba_read

    ;Increment the LBA
    add rax, rcx

    ;Increment the destination

    ;Check the remaining sectors
    sub rbx, 0xFF
    cmp rbx, 0
    jge .loop

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

;=============================================================================
; ATA read sectors (LBA mode) 
;
; @param EAX Logical Block Address of sector
; @param CL  Number of sectors to read
; @param RDI The address of buffer to put data obtained from disk
;
; @return None
;=============================================================================

ata_lba_read:
   pushfq
   and rax, 0x0FFFFFFF
   push rax
   push rbx
   push rcx
   push rdx
   push rdi

   mov rbx, rax         ; Save LBA in RBX

   mov edx, 0x01F6      ; Port to send drive and bit 24 - 27 of LBA
   shr eax, 24          ; Get bit 24 - 27 in al
   or al, 11100000b     ; Set bit 6 in al for LBA mode
   out dx, al

   mov edx, 0x01F2      ; Port to send number of sectors
   mov al, cl           ; Get number of sectors from CL
   out dx, al

   mov edx, 0x1F3       ; Port to send bit 0 - 7 of LBA
   mov eax, ebx         ; Get LBA from EBX
   out dx, al

   mov edx, 0x1F4       ; Port to send bit 8 - 15 of LBA
   mov eax, ebx         ; Get LBA from EBX
   shr eax, 8           ; Get bit 8 - 15 in AL
   out dx, al


   mov edx, 0x1F5       ; Port to send bit 16 - 23 of LBA
   mov eax, ebx         ; Get LBA from EBX
   shr eax, 16          ; Get bit 16 - 23 in AL
   out dx, al

   mov edx, 0x1F7       ; Command port
   mov al, 0x20         ; Read with retry.
   out dx, al

.still_going:  in al, dx
   test al, 8           ; the sector buffer requires servicing.
   jz .still_going      ; until the sector buffer is ready.

   mov rax, 256         ; to read 256 words = 1 sector
   xor bx, bx
   mov bl, cl           ; read CL sectors
   mul bx
   mov rcx, rax         ; RCX is counter for INSW
   mov rdx, 0x1F0       ; Data port, in and out
   rep insw             ; in to [RDI]

   pop rdi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   popfq
   ret

;---
;- 64 bit print utilitity
;---

print_str_64:

    push rax
    push rbx
    push rdx
    push rcx

    mov ecx, [cursor]

.loop:

    ;Wrap the cursor
    cmp ecx, [cursor_max]
    jne .cont
    mov ecx, [cursor_start]

.cont:
    ;Get the new character to write
    mov al, [edx] 

    ;Check if its time to ext
    or al, al
    jz .exit

    ;Commit the text and attribute to memory
    mov [ecx], al
    mov byte [ecx + 1], 1

    ;Increment screen and data pointers
    add edx, 1
    add ecx, 2

    jmp .loop

.exit:
    mov [cursor], ecx
    
    pop rcx
    pop rdx
    pop rbx
    pop rax

    ret

;----
;- Strcmp 8 bytes
;- @param rdi String 1
;- @param si String 2
;----

strcmp_8_16:
    mov cl, 8
    xor ax, ax
    xor bx, bx

.loop:

    lodsb
    add bx, ax

    mov al, [rdi]
    sub bx, ax
    inc di

    dec cl
    jz .exit

    jmp .loop

.exit:
   mov ax, bx
   ret
