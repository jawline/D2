all: kernel

kernel:
	@cd Kernel && $(MAKE)
