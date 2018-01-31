OUT_DIR := bin/
CD_DIR := cd/
CD_OUT := cd.iso

BOOTLOADER := bootloader

.PHONY: all test kernel bootloader build iso

all: build

build: bootloader kernel

kernel:
	@cd kernel && $(MAKE)

bootloader:
	@cd $(BOOTLOADER) && $(MAKE)

iso: build 
	@mkdir -p $(OUT_DIR)$(CD_DIR)
	@cp $(BOOTLOADER)/stage1/bin/* $(OUT_DIR)$(CD_DIR)
	@./scripts/mk_iso $(OUT_DIR)$(CD_DIR) Test stage1.bin $(OUT_DIR)$(CD_OUT)
