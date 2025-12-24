# NASM-first Makefile for a minimal 512-byte boot sector project
SHELL := /bin/bash

# Tools (can be overridden by environment variables)
NASM ?= $(shell which nasm 2>/dev/null || true)
QEMU ?= $(shell which qemu-system-x86_64 2>/dev/null || echo qemu-system-x86_64)
GRUB_MKRESCUE ?= $(shell which x86_64-elf-grub-mkrescue 2>/dev/null || which grub-mkrescue 2>/dev/null || true)
XORRISO ?= $(shell which xorriso 2>/dev/null || true)

# Output
BUILD_DIR := build
BOOT_BIN := $(BUILD_DIR)/boot.bin
ISO := kernel.iso
SCREEN := qemu_screen.ppm
SERIAL_LOG := serial.log

# Boot sector source
ASM := boot/boot.asm

.PHONY: all check-tools boot run run-headless iso run-iso clean distclean help

all: check-tools $(BOOT_BIN)

check-tools:
	@echo "Checking required tools..."
	@echo "NASM: " $(NASM)
	@echo "QEMU: " $(QEMU)
	@if [ -z "$(NASM)" ]; then \
		echo "ERROR: nasm not found. Install with: brew install nasm (macOS) or apt install nasm (WSL)"; exit 1; \
	fi
	@if [ -z "$(QEMU)" ]; then \
		echo "ERROR: qemu-system-x86_64 not found. Install with: brew install qemu or apt install qemu-system-x86"; exit 1; \
	fi
	@echo "OK"

# Build a raw 512-byte boot sector
$(BOOT_BIN): $(ASM)
	@mkdir -p $(BUILD_DIR)
	@echo "Assembling $< -> $@"
	$(NASM) -f bin $< -o $@
	@# verify size and signature
	@sz=$$(wc -c < $@); if [ "$$sz" -ne 512 ]; then echo "ERROR: $@ size is $$sz (expected 512)"; exit 1; fi
	@sig=$$(xxd -g 1 -l 2 -s 510 $@ | awk '{print $$2$$3}'); if [ "$$sig" != "55aa" ] && [ "$$sig" != "aa55" ]; then echo "ERROR: missing 0xAA55 signature in $@ (found: $$sig)"; exit 1; fi
	@echo "$@ is valid (512 bytes, 0xAA55)"

# Run in a GUI window (macOS: -display cocoa). On M-series use accel=tcg for x86_64 emulation
run: $(BOOT_BIN)
	@echo "Running QEMU (GUI) - display may open on your host"
	$(QEMU) -machine accel=tcg -m 512M -fda $(BOOT_BIN) -boot a -serial stdio -display cocoa

# Headless run: redirect serial to file and optionally capture a screenshot via monitor
run-headless: $(BOOT_BIN)
	@echo "Running QEMU headless; serial -> $(SERIAL_LOG)"
	$(QEMU) -machine accel=tcg -m 512M -fda $(BOOT_BIN) -boot a -nographic -serial file:$(SERIAL_LOG) -no-reboot -no-shutdown & QPID=$$!; sleep 2; kill $$QPID || true; echo "Done (serial in $(SERIAL_LOG))"

# Create a GRUB ISO if grub-mkrescue available
iso: $(BOOT_BIN)
	@if [ -z "$(GRUB_MKRESCUE)" ]; then \
		echo "grub-mkrescue not found; install x86_64-elf-grub + xorriso or set GRUB_MKRESCUE environment variable"; exit 1; \
	fi
	@rm -rf iso
	@mkdir -p iso/boot/grub
	@cp $(BOOT_BIN) iso/boot/boot.bin
	@printf 'set timeout=1\nset default=0\nmenuentry "Boot" {\n  multiboot /boot/boot.bin\n  boot\n}\n' > iso/boot/grub/grub.cfg
	@echo "Creating ISO via $(GRUB_MKRESCUE) ..."
	$(GRUB_MKRESCUE) -o $(ISO) iso
	@echo "ISO created: $(ISO)"

run-iso: iso
	@echo "Running kernel ISO in QEMU (GUI)"
	$(QEMU) -machine accel=tcg -m 512M -cdrom $(ISO) -boot d -display cocoa -serial stdio

clean:
	rm -rf $(BUILD_DIR) $(ISO) $(SERIAL_LOG) $(SCREEN) iso

# distclean removes backups or other files (use with caution)
distclean: clean
	@echo "No extra distclean steps"

help:
	@echo "Available targets:"
	@echo "  make            -> build (check-tools + assemble)"
	@echo "  make check-tools -> verify nasm/qemu are installed"
	@echo "  make run        -> run boot.bin in QEMU with GUI (cocoa)"
	@echo "  make run-headless -> run headless and capture serial to $(SERIAL_LOG)"
	@echo "  make iso        -> build a GRUB ISO (requires grub-mkrescue)"
	@echo "  make run-iso    -> run the ISO in QEMU"
	@echo "  make clean      -> remove build artifacts"
	@echo "  make distclean  -> deep clean"
