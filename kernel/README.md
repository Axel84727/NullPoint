# Kernel (Boot Sector) — Hello from NULLPOINT

This directory contains a minimal 512-byte NASM boot sector that sets text mode, clears the screen and prints "Hello from NULLPOINT" in red using direct VGA text memory writes.

Quick goals
- Build a raw 512-byte boot sector: `build/boot.bin`.
- Run it in QEMU (floppy / -fda) to test the boot/visual output.

Prerequisites
- macOS (Homebrew) or Linux/WSL
- Tools: `nasm`, `qemu-system-x86_64` (and optionally `x86_64-elf-grub` + `xorriso` for creating ISOs)

macOS (Homebrew) install

```bash
brew update
brew install nasm qemu xorriso
# Optionally install x86_64-elf-grub if you want grub-mkrescue:
# brew install i686-elf-grub  # or x86_64-elf-grub if available
```

Ubuntu / WSL install

```bash
sudo apt update
sudo apt install nasm qemu-system-x86 xorriso
```

Build

```bash
cd kernel
make            # runs check-tools and assembles build/boot.bin
```

Verify

```bash
wc -c build/boot.bin   # should print 512
xxd -g 1 -l 2 -s 510 build/boot.bin   # should show 55 aa
```

Run (GUI)

```bash
# On macOS this opens a Cocoa window for QEMU
make run
```

Run headless (no window)

```bash
make run-headless
# serial output (if any) is written to serial.log
```

Create ISO (optional)

```bash
make iso
make run-iso
```

Notes
- On Apple Silicon (M-series) QEMU emulates x86_64 using TCG (slow). For faster iteration consider adding a native aarch64 flow.
- The boot sector writes directly to VGA memory (0xB8000). The headless serial run will not show the VGA output; use `make run` to open the GUI and view the text.

Troubleshooting
- If `make run` fails to open a window on macOS, run the equivalent `qemu-system-x86_64` command shown in `Makefile` and ensure `-display cocoa` is supported.
- If `nasm` or `qemu` are not found, install them as shown above.
