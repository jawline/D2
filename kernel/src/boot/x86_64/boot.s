[bits 64]

[global _entry]
[extern rust_entry]

_entry:
    jmp rust_entry
