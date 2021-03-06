;----
;- The following can only be called once in protected mode
;----
[bits 32]

;---
;- Entry Point
;---

entry_protected:
   
    ;Load in the new data segment after the jump
    mov ax, (gdt_32.data - gdt_32.null)
    mov ds, ax 

    mov edx, protected_msg
    call print_str_32

    call check_long_mode

    ;Start setting up the page table for long mode
    call enable_pdt_32

    ;Jump to 64b mode
    jmp enter_64

enter_64:
    lgdt [gdt_64.gdtr]
    jmp gdt_64.code:long_entry

hlt32:
    cli
    hlt

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

    ;Print good-to-go
    mov edx, longmode_supported_msg
    call print_str_32

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
    mov edx, error_nolong_msg
    call print_str_32
    jmp hlt32


;----
;- Paging related stuf
;---

disable_paging_32:
    mov eax, cr0                                   ; Set the A-register to control register 0.
    and eax, 01111111111111111111111111111111b     ; Clear the PG-bit, which is bit 31.
    mov cr0, eax                                   ; Set control register 0 to the A-register.
    ret

; Map the first 2MB of memory in an identity map to the 64 bit page tables (OSDev)
identity_map_pdt:

    ;Clear the tables
    mov edi, 0x1000    ; Set the destination index to 0x1000.
    mov cr3, edi       ; Set control register 3 to the destination index.
    xor eax, eax       ; Nullify the A-register.
    mov ecx, 4096      ; Set the C-register to 4096.
    rep stosd          ; Clear the memory.
    mov edi, cr3       ; Set the destination index to control register 3.    

    mov DWORD [edi], 0x2003      ; Set the uint32_t at the destination index to 0x2003.
    add edi, 0x1000              ; Add 0x1000 to the destination index.
 
    mov DWORD [edi], 0x3003      ; Set the uint32_t at the destination index to 0x3003.
    add edi, 0x1000              ; Add 0x1000 to the destination index.
 
    mov DWORD [edi], 0x4003      ;First PT at 0x4000 in physical memory, it is readable + writable
    mov DWORD [edi + 8], 0x5003  ;Second PT entry (2MB) readable + writable

    add edi, 0x1000              ; Start operating on the PT
    mov ebx, 0x00000003          ; EBX begins with readable | writable
    mov ecx, 1024                ; Loop Count

.set_entry:
    mov DWORD [edi], ebx         ; Set the uint32_t at the destination index to the B-register.
    add ebx, 0x1000              ; Add 0x1000 to the B-register.
    add edi, 8                   ; Add eight to the destination index.
    loop .set_entry              ; Set the next entry.

    mov eax, cr4                 ; Set the A-register to control register 4.
    or eax, 1 << 5               ; Set the PAE-bit, which is the 6th bit (bit 5).
    mov cr4, eax                 ; Set control register 4 to the A-register.

    ret

;Identity map the PDT and then enable 64bit compat mode
enable_pdt_32:

    call disable_paging_32
    call identity_map_pdt

    mov ecx, 0xC0000080          ; Set the C-register to 0xC0000080, which is the EFER MSR.
    rdmsr                        ; Read from the model-specific register.
    or eax, 1 << 8               ; Set the LM-bit which is the 9th bit (bit 8).
    wrmsr                        ; Write to the model-specific register.

    mov eax, cr0                 ; Set the A-register to control register 0.
    or eax, 1 << 31              ; Set the PG-bit, which is the 32nd bit (bit 31).
    mov cr0, eax                 ; Set control register 0 to the A-register.

    ;Print success
    mov edx, paging_enabled_msg
    call print_str_32
    
    ret 

;---
;- 32 bit helpers
;---

cursor dd 0xB8000
cursor_start dd 0xB8000
cursor_max dd (0xB8000 + 0xFA0)

reset_cursor:
    mov eax, [cursor_start]
    mov [cursor], eax
    ret

print_str_32:
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
