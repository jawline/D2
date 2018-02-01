[bits 16]

start:

    ;Clear initial state
    xor ax, ax
    mov ds, ax
    mov es, ax

    ;Clear screen
    mov al, 3
    mov ah, 0
    int 0x10

    ;Disable interrupts to begin
    cli

    ;Say hello
    mov si, stage_msg
    call printstr_32

    ;Get ready for magical kernel land
    call enable_a20
    call load_gdt_32
    call enter_protected_mode

hlt:
    cli
    hlt

;----
;- Enable A20
;----

enable_a20:

    ;Print A20 msg
    mov si, enable_a20_msg
    call printstr_32
    
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
    call printstr_32
    ret

;----
;- GDT
;----

load_gdt_32:
    mov si, gdt_msg
    call printstr_32

    lgdt [gdt_32.gdtr]

    mov si, done_msg
    call printstr_32
 
    ret

;----
;- Entering protected mode
;----
enter_protected_mode:
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp (gdt_32.code - gdt_32.null):entry_protected
    

;-----
;- Helper methods
;-----

printstr_32:
   cld                    ; clear df flag - lodsb increments si

.loop:
   lodsb                  ; load next character into al, increment si
   or al, al              ; sets zf if al is 0x00
   jz .end
   mov ah, 0x0E           ; teletype output (int 0x10)
   int 0x10               ; print character
   jmp .loop

.end:
   ret
