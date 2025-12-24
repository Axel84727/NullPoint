#!/usr/bin/env bash
# @brief Start QEMU with gdb server for debugging the boot sector
# Usage: ./scripts/debug_gdb.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOOT_BIN="${ROOT_DIR}/build/nullpoint.bin"

if [ ! -f "${BOOT_BIN}" ]; then
  echo "No boot image found. Run ./scripts/build.sh first."
  exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "qemu-system-x86_64 not found in PATH. Install qemu to debug the image."
  exit 1
fi

# Start QEMU paused and listening for gdb on TCP port 1234
qemu-system-x86_64 -drive format=raw,file="${BOOT_BIN}",if=floppy -serial stdio -S -gdb tcp::1234

# Tip: from another shell run:
#   gdb -q
#   (gdb) set architecture i8086
#   (gdb) target remote :1234
#   (gdb) break *0x7c00
#   (gdb) continue

