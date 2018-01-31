[bits 16]

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
;- GDT
;----

;Space for a GDT table
gdt_start:

null_descriptor:
    dq 0x0 ;Create a null descriptor

;Code segment
code_descriptor:
    dw 0xFFFF ;limit low
    dw 0 ;base low
    db 0 ;base middle
    db 10011010b ;Access
    db 11001111b
    db 0 ;base high

;Data segment
data_descriptor:
    dw 0xFFFF ;limit low
    dw 0 ;base low
    db 0 ;base middle
    db 10010010b ;Access
    db 11001111b
    db 0 ;base high
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
