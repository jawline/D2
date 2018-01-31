OUT_DIR := bin/

CD_DIR := cd/
CD_OUT := cd.iso

IMG_OUT := base.img

BOOTLOADER := bootloader
BL_OUT := $(OUT_DIR)$(BOOTLOADER)
BL_IMG := $(OUT_DIR)bootloader.img

.PHONY: all test kernel bootloader build iso

all: img

build: bootloader kernel

kernel:
	@cd kernel && $(MAKE)

bootloader:
	@cd $(BOOTLOADER) && $(MAKE)

clean:
	@cd kernel && $(MAKE) clean
	@cd bootloader && $(MAKE) clean
	@rm -rf bin

bootloader_img:
	@mkdir -p $(BL_OUT)
	@rm -f $(BL_IMG)
	@cp $(BOOTLOADER)/stage1/bin/stage1.bin $(BL_OUT)
	@cp $(BOOTLOADER)/stage2/bin/stage2.bin $(BL_OUT)
	@cat $(BL_OUT)/stage1.bin > $(BL_IMG)
	@cat $(BL_OUT)/stage2.bin >> $(BL_IMG)

img: build bootloader_img


iso: img  
	@mkdir -p $(OUT_DIR)$(CD_DIR)
	@cp $(BOOTLOADER)/stage1/bin/* $(OUT_DIR)$(CD_DIR)
	@./scripts/mk_iso $(OUT_DIR)$(CD_DIR) Test stage1.bin $(OUT_DIR)$(CD_OUT)
