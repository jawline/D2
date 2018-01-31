all: build

build: bootloader image

kernel:
	@(cd kernel && $(MAKE))

bootloader:
	@(cd bootloader && $(MAKE))
