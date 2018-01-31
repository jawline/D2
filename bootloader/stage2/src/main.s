; Stage 2 start
org 0x07E00

; we are targeting (x86) 16-bit real mode
bits 16

jmp start

stage_msg db "Stage 2 Starting", 13, 10, 0
enable_a20_msg db "Enable A20", 13, 10, 0
segments_msg db "Reloading Segments", 13, 10, 0
gdt_msg db "GDT", 13, 10, 0
done_msg db "Done", 13, 10, 0
error_nolong_msg db "Error: No Long Mode", 13, 10, 0
longmode_supported_msg db "Machine is 64bit", 13, 10, 0

start:

    ;Clear initial state
    xor ax, ax
    mov ds, ax
    mov es, ax

    ;Clear screen
    mov al, 2
    mov ah, 0
    int 0x10

    ;Disable interrupts to begin
    cli

    ;Say hello
    mov si, stage_msg
    call printstr

    ;Get ready for magical kernel land
    call enable_a20
    call load_gdt
    call check_long_mode

    call enter_protected_mode
hlt:
    jmp hlt

;----
;- Enable A20
;----

enable_a20:

    ;Print A20 msg
    mov si, enable_a20_msg
    call printstr
    
    ;We support only the fast A20 gate

    ;Check if already enabled
    in al, 0x92
    test al, 2
    jnz enable_a20_already

    ;Use the fast switch
    or al, 2
    and al, 0xFE
    out 0x92, al

enable_a20_already:

    ;Print success
    mov si, done_msg
    call printstr
    ret

;----
;- CPUID 64 bit check (From OSDev)
;----

check_long_mode:
    call check_cpuid

    ;Find out if the CPUID flag to check long mode exists
    mov eax, 0x80000000    ; Set the A-register to 0x80000000.
    cpuid                  ; CPU identification.
    cmp eax, 0x80000001    ; Compare the A-register with 0x80000001.
    jb hlt_nolongmode         ; It is less, there is no long mode.

    ;Test the long mode CPUID instr
    mov eax, 0x80000001    ; Set the A-register to 0x80000001.
    cpuid                  ; CPU identification.
    test edx, 1 << 29      ; Test if the LM-bit, which is bit 29, is set in the D-register.
    jz hlt_nolongmode         ; They aren't, there is no long mode.

    mov si, longmode_supported_msg
    call printstr

    ret

check_cpuid:
    pushfd
    pop eax
 
    ; Copy to ECX as well for comparing later on
    mov ecx, eax
 
    ; Flip the ID bit
    xor eax, 1 << 21
 
    ; Copy EAX to FLAGS via the stack
    push eax
    popfd
 
    ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pushfd
    pop eax
 
    ; Restore FLAGS from the old version stored in ECX (i.e. flipping the ID bit
    ; back if it was ever flipped).
    push ecx
    popfd
 
    ; Compare EAX and ECX. If they are equal then that means the bit wasn't
    ; flipped, and CPUID isn't supported.
    xor eax, ecx
    jz hlt_nolongmode
    ret

hlt_nolongmode:
    mov si, error_nolong_msg
    call printstr
    jmp hlt

;----
;- GDT
;----

;Space for a GDT table
gdt_start:

null_descriptor:
    dq 0x0 ;Create a null descriptor

;Code segment
code_descriptor:
    dq 0x0 ;Selector 0x08 will be code

;Data segment
data_descriptor:
    dq 0x0 ;Selector 0x10 will be data

gdt_end:

;GDT Table Record
gdtr:
    dw gdt_end - gdt_start - 1 ;Limit
    dd gdt_start ;Base

load_gdt:
    mov si, gdt_msg
    call printstr

    lgdt [gdtr]

    mov si, done_msg
    call printstr
 
    ret

;----
;- Entering protected mode
;----
enter_protected_mode:
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp (code_descriptor - null_descriptor):entry_protected
    

;-----
;- Helper methods
;-----

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

[bits 32]

entry_protected:
    mov al, 2
    mov ah, 0
    int 0x10
hlt32:
    jmp hlt32

;Pad to 4kb
times 4094 - ($ - $$) db 0x00
