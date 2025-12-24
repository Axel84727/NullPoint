Kernel minimal

This folder contains a minimal freestanding x86_64 kernel example and a small build flow to run it in QEMU.

Important note for Apple Silicon (M1/M2/M3/M4): running an x86_64 guest on Apple Silicon is emulated and will be slower (TCG). QEMU accel=hvf cannot accelerate an x86_64 guest on Apple Silicon. If you want native speed on Apple Silicon consider building an aarch64 kernel instead.

Prerequisites (macOS, zsh)
- Homebrew (https://brew.sh/)
- Basic packages: qemu, nasm, llvm (includes clang/lld/llvm-objcopy), binutils (gobjcopy), gdb, make

Quick start (recommended)
1) Install Homebrew (if you don't have it):

   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

2) Run the helper setup script to install packages:

   cd kernel
   chmod +x setup.sh
   ./setup.sh

3) Add Homebrew llvm to your PATH for this session (Homebrew prefix is detected by the script):

   export PATH="$(brew --prefix)/opt/llvm/bin:$PATH"

4) Build the kernel:

   make

   This will produce `build/kernel.elf` and `build/kernel.bin`.

5) Run the kernel in QEMU (this will start QEMU and wait for a GDB connection on port 1234):

   make run

   If your Mac is Apple Silicon, QEMU will likely use TCG for x86_64 emulation. If `-machine accel=hvf` fails, the Makefile will fall back to TCG if you edit the run command.

6) Debug with GDB (in another terminal):

   make gdb

   Inside GDB:
     (gdb) target remote :1234
     (gdb) break kernel_main
     (gdb) continue

Notes and next steps
- The `boot/boot.S` file in this example is a tiny start stub that jumps to `kernel_main`. For a robust boot sequence use GRUB/multiboot (generate a bootable ISO) or add a full 16/32->64-bit bootstrap.
- If you want to target Apple Silicon natively, I can add an aarch64 build flow (toolchain flags, linker script and QEMU invocation) — tell me if you prefer that.

Files of interest
- Makefile — minimal build flow (detects cross-toolchain if present, otherwise uses clang/lld/llvm-objcopy)
- linker/linker.ld — minimal linker script placing the kernel at 0x100000
- boot/boot.S — very small start stub
- src/main.c — kernel entry (kernel_main)
- setup.sh — helper script to install dependencies using Homebrew

If you want, I can also convert this to a GRUB+ISO flow to boot the kernel more realistically. If you run the setup steps and `make` and get any errors, paste the output here and I'll fix them and commit the changes.
