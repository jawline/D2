OUT_DIR := bin/
CD_DIR := cd/
CD_OUT := cd.iso

BOOTLOADER := bootloader

.PHONY: all test kernel bootloader build iso

all: iso

build: bootloader kernel

kernel:
	@cd kernel && $(MAKE)

bootloader:
	@cd $(BOOTLOADER) && $(MAKE)

clean:
	@cd kernel && $(MAKE) clean
	@cd bootloader && $(MAKE) clean
	@rm -rf bin

iso: build 
	@mkdir -p $(OUT_DIR)$(CD_DIR)
	@cp $(BOOTLOADER)/stage1/bin/* $(OUT_DIR)$(CD_DIR)
	@./scripts/mk_iso $(OUT_DIR)$(CD_DIR) Test stage1.bin $(OUT_DIR)$(CD_OUT)
