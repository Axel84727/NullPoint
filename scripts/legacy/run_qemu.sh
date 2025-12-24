#!/usr/bin/env bash
# @brief Run the built NullPoint image in QEMU
# Usage: ./scripts/run_qemu.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOOT_BIN="${ROOT_DIR}/build/nullpoint.bin"

if [ ! -f "${BOOT_BIN}" ]; then
  echo "No boot image found. Run ./scripts/build.sh first."
  exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "qemu-system-x86_64 not found in PATH. Install qemu to run the image."
  exit 1
fi

# Run QEMU with floppy drive and serial output to stdio
qemu-system-x86_64 -drive format=raw,file="${BOOT_BIN}",if=floppy -serial stdio -no-reboot

