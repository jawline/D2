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

    ;Load the SMAP adress into DI for the kernel
    mov di, $$ + stage_2_size
    jmp kernel_target_addr
