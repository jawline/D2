#Makefile for SimpleOS Kernel

OUT_DIR := bin/
OUTPUT_FILE := $(OUT_DIR)kernel.bin
SOURCE_DIRS := ./src/

CSOURCES := $(shell find $(SOURCE_DIRS) -name \*.c)
SSOURCES := $(shell find $(SOURCE_DIRS) -name \*.s)
OBJECTS := $(patsubst %.s,%.o,$(SSOURCES)) $(patsubst %.c,%.o,$(CSOURCES))

CFLAGS=-nostdlib -std=c99 -nostdinc -fno-builtin -fno-stack-protector -m64 -Wall
LDFLAGS=-Tlink.ld
ASFLAGS=-felf64

all: link

clean:
	-@rm $(OBJECTS) $(OUTPUT_FILE)

sources:
	@echo "Looking in" $(SOURCE_DIRS)
	@echo $(SSOURCES)
	@echo $(CSOURCES)

link: $(OBJECTS)
	@echo "Linking" $(CSOURCES)
	@ld $(LDFLAGS) -o $(OUTPUT_FILE) $(OBJECTS) 
