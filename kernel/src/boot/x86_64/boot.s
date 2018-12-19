[bits 64]

[extern rust_entry]

[global _d2_entry]
_d2_entry:
	jmp rust_entry
