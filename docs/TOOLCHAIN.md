# Toolchain installation (macOS & WSL/Linux)

@brief Quick instructions to install required tools for NullPoint development.

macOS (Homebrew):

1. Install Homebrew (if not installed):
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
2. Install required packages:
   brew install nasm qemu gdb

WSL / Ubuntu:

sudo apt update
sudo apt install -y nasm qemu-system-x86 gdb make build-essential

Notes:
- On macOS, gdb may require code-signing. Use lldb if preferred or follow gdb code-sign instructions.
- For cross-compilers and more advanced builds, consider installing i386-elf-gcc toolchains.
- This project uses NASM for assembling the 16-bit boot sector; no python is required.

