[bits 64]

long_entry:
    cli                           ; Clear the interrupt flag.

    mov ax, gdt_64.data           ; Set the A-register to the data descriptor.
    mov ds, ax                    ; Set the data segment to the A-register.
    mov es, ax                    ; Set the extra segment to the A-register.
    mov fs, ax                    ; Set the F-segment to the A-register.
    mov gs, ax                    ; Set the G-segment to the A-register.
    mov ss, ax                    ; Set the stack segment to the A-register.

    mov edi, 0xB8000              ; Set the destination index to 0xB8000.
    mov rax, 0xFFFFFFFFFFFFFFFF   ; Set the A-register to 0x1F201F201F201F20.
    mov ecx, 500                  ; Set the C-register to 500.
    rep stosq                     ; Clear the screen.

    hlt                           ; Halt the processor.
