[bits 16]

smap_msg db "SMAP", 13, 10, 0
smap_err db "SMAP Error", 13, 10, 0

;---
;- SMAP Loader
;- An SMAP entry is (up to) 24 bytes of memory laid out as
;- qword (origin + 0)  address
;- qword (origin + 8)  length
;- dword (origin + 16) type
;- dword (origin + 20) acpi 3 attributes
;---

;Load SMAP to address pointed to by DI
load_smap:
    xor ebx, ebx

.loop:
    
    ;Registers might be trashed in loop or interrupt
    mov eax, 0xE820 ;INT 15 AX=0xE820 is SMAP
    mov ecx, 24
    mov edx, 0x534D4150 ;SMAP in ASCII

    ;This makes ACPI happy
    mov [es:di + 20], dword 1

    int 0x15
    jc .fail

    ;We can ignore entries with a length of zero
    ;bytes 8-16 of the SMAP entry are the entry length

    ;Do a 8 byte null est by oring two 4-byte data elements together
    mov ecx, [es:di + 8]
    or  ecx, [es:di + 12]
    jz .dont_inc
    
    ;If length != 0 then increment DI otherwise reuse it
    add di, 24

.dont_inc:
    or ebx, ebx
    jnz .loop

.exit:
    ;Null entry at the end
    mov [di], dword 0
    mov [di + 4], dword 0
    mov [di + 8], dword 0
    mov [di + 12], dword 0
    mov [di + 16], dword 0
    mov [di + 20], dword 0 
    mov ax, 1

    ret

.fail:

    mov si, smap_err
    call print_str_16

    jmp $

    mov ax, 0
    ret
