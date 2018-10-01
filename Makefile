AS := nasm

OUT_DIR := bin/

CD_DIR := cd/
CD_OUT := cd.iso

IMG_OUT := base.img

BOOTLOADER := bootloader
BL_OUT := $(OUT_DIR)$(BOOTLOADER)
BL_IMG := $(OUT_DIR)bootloader.img

KERNEL_OUT := $(OUT_DIR)kernel

KERNEL := kernel

QEMU := qemu-system-x86_64

.PHONY: all test kernel bootloader build img_create iso

all: img

build: bootloader kernel

kernel:
	@mkdir -p $(OUT_DIR)
	@cd $(KERNEL) && $(MAKE)
	@cp $(KERNEL)/bin/kernel.bin $(KERNEL_OUT)

bootloader:
	@mkdir -p $(BL_OUT)
	@cd $(BOOTLOADER) && $(MAKE)
	@cp $(BOOTLOADER)/stage1/bin/stage1.bin $(BL_OUT)
	@cp $(BOOTLOADER)/stage2/bin/stage2.bin $(BL_OUT)

clean:
	@cd kernel && $(MAKE) clean
	@cd bootloader && $(MAKE) clean
	@cd img_create && $(MAKE) clean
	@rm -rf bin

img_create:
	@cd img_create && $(MAKE)

bootloader_img: img_create
	@rm -f $(BL_IMG)
	@img_create/bin/img_create $(BL_OUT)/stage1.bin $(BL_OUT)/stage2.bin $(KERNEL_OUT) $(BL_IMG)

img: build bootloader_img

test: img
	@$(QEMU) -monitor stdio -hda $(BL_IMG) 

