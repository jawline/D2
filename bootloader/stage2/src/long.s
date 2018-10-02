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

    ret

;----
;- Load root directory
;- @param rdi - target destination for root directory

load_root_dir:

    mov edx, load_root_dir_msg
    call print_str_64

    ret

;----
;- Load the kernel
;----

load_kernel:

    mov edx, loading_kernel
    call print_str_64

    call load_fat_1
    call load_root_dir

.loop:
    jmp .loop

    ret

;---
;- 64 bit print utilitity
;---

print_str_64:
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
