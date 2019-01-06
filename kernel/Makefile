TARGET := x86_64
BUILD_MODE := release

OUT_DIR := bin/
OUTPUT_FILE := $(OUT_DIR)kernel.bin

SBOOTSOURCE := src/boot/${TARGET}/boot
LDFLAGS=--architecture=x86_64 --oformat binary -Ttext 0x100000 -entry=_d2_entry
ASFLAGS=-felf64

RUST_OS_OBJECT := ./target/$(TARGET)/$(BUILD_MODE)/libd2_kernel.a

all: link

clean:
	-@rm -rf ./target/
	-@rm $(OBJECTS) $(OUTPUT_FILE)

rust_lib:
	@RUST_TARGET_PATH=$(shell pwd) xargo build --${BUILD_MODE} --target $(TARGET)

link: rust_lib
	@echo "Linking" $(CSOURCES)
	@mkdir -p $(OUT_DIR)
	@$(AS) $(ASFLAGS) -o "$(SBOOTSOURCE).o" "$(SBOOTSOURCE).s"
	@ld $(LDFLAGS) -o $(OUTPUT_FILE) $(SBOOTSOURCE).o $(RUST_OS_OBJECT)
