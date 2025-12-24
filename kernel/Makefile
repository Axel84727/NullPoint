# Makefile mínimo para construir un kernel x86_64 freestanding
# Detecta herramientas cross (x86_64-elf-*) si están instaladas, si no usa clang/ld.lld/objcopy cuando estén disponibles.

CROSS ?= x86_64-elf

XGCC := $(shell which $(CROSS)-gcc 2>/dev/null)
XLD  := $(shell which $(CROSS)-ld 2>/dev/null)
XOBJCOPY := $(shell which $(CROSS)-objcopy 2>/dev/null)
XGDB := $(shell which $(CROSS)-gdb 2>/dev/null)

CLANG := $(shell which clang 2>/dev/null)
LD_LLD := $(shell which ld.lld 2>/dev/null)
# prefer llvm-objcopy (Homebrew llvm) or gobjcopy (binutils) before plain objcopy
LLVM_OBJCOPY := $(shell which llvm-objcopy 2>/dev/null)
GOBJCOPY := $(shell which gobjcopy 2>/dev/null)
OBJCOPY := $(shell which objcopy 2>/dev/null)
QEMU := $(shell which qemu-system-x86_64 2>/dev/null || echo qemu-system-x86_64)
GDB := $(shell which gdb 2>/dev/null || echo gdb)

# Choose toolchain: prefer cross tools if present
CC := $(or $(XGCC),$(CLANG))
LD := $(or $(XLD),$(LD_LLD),$(shell which ld 2>/dev/null))
# final OBJCOPY selection prefers cross, then llvm-objcopy, then gobjcopy, then objcopy
OBJCOPY := $(or $(XOBJCOPY),$(LLVM_OBJCOPY),$(GOBJCOPY),$(OBJCOPY))
GDB_CLIENT := $(or $(XGDB),$(GDB))

NASM := $(shell which nasm 2>/dev/null || echo nasm)

CFLAGS := -nostdlib -ffreestanding -fno-builtin -fno-stack-protector -O2 -Wall -Wextra -m64
ASFLAGS := -f elf64
LDFLAGS := -T linker/linker.ld -nostdlib

SRC := src/main.c
ASM := boot/boot.S
BUILD_DIR := build

.PHONY: all run gdb clean
all: $(BUILD_DIR)/kernel.bin

# Assemble (using clang/gcc as portable assembler or as -c for .S)
boot/boot.o: $(ASM)
	@mkdir -p boot
	$(CC) -c $(ASM) -o $@ $(CFLAGS)

$(BUILD_DIR)/main.o: $(SRC)
	@mkdir -p $(BUILD_DIR)
	$(CC) -c $(SRC) -o $@ $(CFLAGS)

$(BUILD_DIR)/kernel.elf: boot/boot.o $(BUILD_DIR)/main.o linker/linker.ld
	$(LD) $(LDFLAGS) boot/boot.o $(BUILD_DIR)/main.o -o $@

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $< $@

run: $(BUILD_DIR)/kernel.bin
	# Use accel=hvf on macOS Intel/Apple Silicon when available; fallback to tcg
	$(QEMU) -machine accel=hvf -m 512M -kernel $(BUILD_DIR)/kernel.bin -serial stdio -s -S

gdb: $(BUILD_DIR)/kernel.elf
	$(GDB_CLIENT) $< -ex "target remote :1234"

clean:
	rm -rf $(BUILD_DIR) boot/*.o

