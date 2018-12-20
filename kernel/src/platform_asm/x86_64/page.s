[bits 64]
[global install_pd4]
[global invalidate_pd4]

install_pd4:
	mov cr3, rdi
	mov rax, cr0
	or rax, 0x80000001
	mov cr0, rax
	ret

invalidate_pd4:
	mov rax, cr3
	mov cr3, rax
	ret

invalidate_page:
	invlpg [rdi]
	ret
