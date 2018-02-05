[bits 64]

screen_ptr dd 0xB8000
screen_size dd ((80 * 25) / 4)

long_entry:
    cli                           ; Clear the interrupt flag.

    ;Update the stack register
    mov ax, gdt_64.data           ; Set the A-register to the data descriptor.
    mov ds, ax                    ; Set the data segment to the A-register.
    mov es, ax                    ; Set the extra segment to the A-register.
    mov fs, ax                    ; Set the F-segment to the A-register.
    mov gs, ax                    ; Set the G-segment to the A-register.
    mov ss, ax                    ; Set the stack segment to the A-register.

    jmp kernel_target_addr

hlt_64:
    cli
    hlt                           ; Halt the processor.

;Write rax repeatedly into the screen ptr
clear_screen_64: 
    mov edi, [screen_ptr]              ; Point to screen memory
    mov ecx, [screen_size]      ; Set the loop count to screen size
    rep stosq                     ; Clear the screen.   
    ret
