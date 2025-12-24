#!/usr/bin/env bash
set -euo pipefail

# setup.sh - install required dependencies on macOS using Homebrew
# Usage: ./setup.sh

echo "Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  cat <<'EOF'
Homebrew is not installed. Install it with:

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

After installing Homebrew re-run this script.
EOF
  exit 1
fi

echo "Updating Homebrew..."
brew update

PACKAGES=(qemu nasm llvm binutils gdb make)

echo "Installing: ${PACKAGES[*]}"
brew install "${PACKAGES[@]}"

BREW_PREFIX=$(brew --prefix)
# On Apple Silicon Homebrew path is /opt/homebrew, on Intel /usr/local
LLVM_BIN="${BREW_PREFIX}/opt/llvm/bin"

cat <<EOF

Installation complete. To use Homebrew llvm in this session, add:

  export PATH="${LLVM_BIN}:\$PATH"

Important note for Apple Silicon (M1/M2/M3/M4):
- Running an x86_64 guest on Apple Silicon is emulated (TCG) and will be slower. QEMU's HVF accelerator does not accelerate x86_64 guests on Apple Silicon.
- If you want better performance on Apple Silicon, consider building an aarch64 guest/kernel and running it with -machine accel=hvf.

GDB code-signing (manual):
  1) Open Keychain Access -> Certificate Assistant -> Create a Certificate
     - Name: gdb-cert
     - Identity Type: Self Signed Root
     - Type: Code Signing
     - Create and set to "Always Trust"
  2) Sign gdb:
     sudo codesign -s gdb-cert $(which gdb)
  3) Verify:
     codesign -vvv $(which gdb)

Build and run:
  make -C kernel
  make -C kernel run

Debugging (in another terminal):
  make -C kernel gdb

EOF

