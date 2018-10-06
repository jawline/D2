[bits 64]

fat_start dq 0
root_directory_start dq 0
first_cluster_lba dq 0

long_entry:
    cli                           ; Clear the interrupt flag.

    ;Update the stack register
    mov ax, gdt_64.data           ; Set the A-register to the data descriptor.
    mov ds, ax                    ; Set the data segment to the A-register.
    mov es, ax                    ; Set the extra segment to the A-register.
    mov fs, ax                    ; Set the F-segment to the A-register.
    mov gs, ax                    ; Set the G-segment to the A-register.
    mov ss, ax                    ; Set the stack segment to the A-register.

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

    mov [fat_start], rdi

    xor rax, rax
    xor rbx, rbx

    mov word ax, [reserved_sectors]
    mov word bx, [sectors_per_fat]

    call read_from_disk

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

    mov [root_directory_start], rdi

    ;Calculate CL=size of root directory in sectors
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx

    mov word ax, [root_dir_entries]
    mov word bx, bytes_per_dir_entry ;AX *= bytes_per_dir_entry
    mul ebx

    mov word bx, sector_size ;AX /= sector_size
    div ebx
    add rax, 1
    push rax ;Push the sector count

    ;Calculate the start of the root directory
    xor rax, rax
    xor ebx, ebx

    mov word ax, [sectors_per_fat] 
    mov byte bl, [total_fats]
    mul bx

    mov word bx, [reserved_sectors]
    add eax, ebx

    pop rbx ;Pop sector count to RBX

    call read_from_disk

    add rax, rbx
    sub rax, 1
    mov [first_cluster_lba], rax

    mov edx, loaded_msg
    call print_str_64

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

;---
;- Find the kernel record
;- @param rdi - Pointer to the root directory
;- @returns rdi - 0 or pointer to the root record
;---

find_kernel_record:

    mov edx, search_kernel_record_msg
    call print_str_64

.loop: 

    mov rsi, kernel_name
    mov rdx, kernel_name_len
    call strncmp

    cmp rax, 0
    je .found

    add rdi, bytes_per_dir_entry
    jmp .loop

.found:

    mov edx, loaded_msg
    call print_str_64

    ret

;----
;- Resolve record to a starting cluster index
;- @param rdi - Pointer to record in memory
;- @returns rax - Cluster number
;----

get_cluster_number:
    push rdi

    xor rax, rax

    add rdi, directory_entry_cluster_offset
    mov word ax, [rdi]        

    pop rdi
    ret


;----
;- Resolve next cluster from currently cluster
;- @param rax - Current cluster
;- @returns rax - Next cluster number, EOF if rax >= 0xFFF7 
;----

next_cluster:
    push rdi

    mov rdi, [fat_start]

    mov rbx, 2
    mul rbx
    add rdi, rax

    xor rax, rax
    mov word ax, [rdi]

    pop rdi
    ret

;----
;- Resolve cluster number of LBA sector number
;- @param rax - cluster to convert
;- @returns rax - sector to load
;----

cluster_to_sector:

    push rbx

    xor rbx, rbx
    mov byte bl, [sectors_per_cluster]
    mul rbx
    add rax, [first_cluster_lba]
    
    pop rbx

    ret

print_current_target:
    push rax
    push rdx
    push rdi

    mov rax, rdi
    mov rdi, scratch_msg
    call itoa

    mov rdx, rdi
    call print_str_64

    pop rdi
    pop rdx
    pop rax
    ret

;----
;- Load File
;- @param rax The starting cluster to load
;- @param rdi The destination to place the file
;- @returns None
;----

load_file:

    mov edx, load_file_msg
    call print_str_64

.loop:

    mov edx, step_msg
    call print_str_64

    call print_current_target

    cmp rax, 0xFFF7
    jge .exit

    ;Read the cluster into memory
    push rax
 
    call cluster_to_sector

    xor rbx, rbx
    mov byte bl, [sectors_per_cluster]
    call read_from_disk

    pop rax

    ;Move on to the next cluster
    call next_cluster

    jmp .loop

.exit:
 
    mov edx, loaded_msg
    call print_str_64

    ret  

;----
;- Load the kernel
;----

load_kernel:

    mov edx, loading_kernel
    call print_str_64

    mov rdi, 0x9000
    call load_fat_1
    call load_root_dir

    mov rdi, [root_directory_start]
    call find_kernel_record

    mov edx, cant_find_kernel_msg
    cmp rdi, 0
    je panic

    call get_cluster_number

    mov rdi, kernel_target_addr 
    call load_file

    ret

.failed:

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

    xor rcx, rcx

.loop:

    mov cl, 1
    call ata_lba_read

    ;Increment the LBA
    add rax, rcx

    ;Increment the destination
    push rax

    mov rax, sector_size
    mul rcx
    add rdi, rax

    pop rax

    ;Check the remaining sectors
    sub rbx, 1
    jnz .loop

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

;------
; Strlen of string
; @param rdi - Target string
; @returns rax - Length of string
;------

strlen: 
    mov rax, 0

.loop:
    cmp byte [rdi + rax], 0
    je .exit

    inc rax
    jmp .loop

.exit:
    ret

strrev:
    push rsi
    push rdi

    mov rsi, rdi
    call strlen
    add rdi, rax
    sub rdi, 1

.step_fn:

    cmp rsi, rdi
    jge .exit
    
    mov al, [rsi]
    mov ah, [rdi]

    mov [rdi], al
    mov [rsi], ah

    inc rsi
    dec rdi

    jmp .step_fn

.exit:

    pop rdi
    pop rsi

    ret

;-------
; Integer to string
; @param rax - Integer to convert 
; @param rdi - Target string destination
;-------

itoa:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    cmp rax, 0
    jne .is_not_zero

.is_zero: ;Handle the 0 case explicitely
    mov byte [rdi], '0'
    inc rdi
    jmp .exit

.is_not_zero: ;A loop while num (rax) is not zero, repeatedly divide num by itself

    ;Set RCX = base
    mov rcx, 16

    mov rdx, 0
    div rcx

    cmp rdx, 10
    jge .greater_than_ten

.less_than_10:
    add rdx, '0'
    jmp .reloop

.greater_than_ten:
    add rdx, 'a'

.reloop:
    mov byte [rdi], dl
    inc rdi

    cmp rax, 0
    jne .is_not_zero    
    
.exit:
    mov byte [rdi], 0

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    call strrev

    ret

;----
; Compare up to n bytes in strings 
; @param rdi - str1
; @param rsi - str2
; @param rdx - max number of characters
; @returns rax - 0 if equal
;----

strncmp:
    push rdi

    xor rax, rax

.loop:

    cmp rdx, 0
    jz .done

    mov al, [rdi]
    sub al, [rsi]

    cmp byte [rdi], 0
    jz .done

    cmp byte [rsi], 0
    jz .done

    inc rdi
    inc rsi
    dec rdx

.done:

    pop rdi
    ret

;----
;- Panic: Display reason then wait forever
;- @param rsi - error message
;----

panic:
    cli
    mov rdx, rsi
    call print_str_64
.loop:
    jmp .loop
