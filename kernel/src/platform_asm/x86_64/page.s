[bits 64]
[global install_pagedirectory]

install_pagedirectory:
	mov cr3, rdi
	mov rax, cr0
	or rax, 0x80000001
	mov cr0, rax
	ret
