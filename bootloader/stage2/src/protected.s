;----
;- The following can only be called once in protected mode
;----
[bits 32]

;---
;- Entry Point
;---

entry_protected:
   
    ;Load in the new data segment after the jump
    mov ax, (data_descriptor - null_descriptor)
    mov ds, ax 

    mov edx, empty_screen
    call print_str_32
    call reset_cursor

    mov edx, protected_msg
    call print_str_32

    call check_long_mode

hlt32:
    jmp hlt32

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
    jmp hlt

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

cursor_next_line:
    mov eax, [cursor]
    
    ;Remove the ptr
    sub eax, [cursor_start]

    ;Go to next line
    add eax, 0xA0
    
    mov ecx, eax

    ;Divide and grab modulo 
    mov ebx, eax
    xor edx, edx
    xor eax, eax
    mov eax, 0xA0
    div ebx

    sub ecx, eax
   
    add ecx, [cursor_start]
   
    ;Store modified cursor 
    mov [cursor], ecx
    ret

print_str_32:
    mov ecx, [cursor]

print_str_32_loop:

    ;Wrap the cursor
    cmp ecx, [cursor_max]
    jne print_str_32_cont
    mov ecx, [cursor_start]

print_str_32_cont:

    ;Get the new character to write
    mov al, [edx] 

    ;Check if its time to ext
    or al, al
    jz print_str_32_exit

    ;Commit the text and attribute to memory
    mov [ecx], al
    mov byte [ecx + 1], 1

    ;Increment screen and data pointers
    add edx, 1
    add ecx, 2

    jmp print_str_32_loop

print_str_32_exit:
    mov [cursor], ecx
    call cursor_next_line
    ret
 
