#!/usr/bin/env bash
# Run QEMU with a GUI so you can see the VGA text output.
# Usage: ./scripts/run_qemu_gui.sh [--serial]
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOOT_BIN="$ROOT_DIR/build/nullpoint.bin"
QEMU="qemu-system-i386"

if [ ! -f "$BOOT_BIN" ]; then
  echo "No boot image found at $BOOT_BIN"
  echo "Run ./scripts/build_boot.sh first"
  exit 1
fi

# choose display backend: cocoa for macOS, gtk for others
UNAME="$(uname -s)"
DISPLAY_OPT=""
if [ "$UNAME" = "Darwin" ]; then
  DISPLAY_OPT="-display cocoa"
else
  DISPLAY_OPT="-display gtk"
fi

SERIAL_OPT=""
if [ "${1:-}" = "--serial" ]; then
  SERIAL_OPT="-serial stdio"
fi

# start QEMU with GUI (not headless)
echo "Starting QEMU with GUI..."
exec "$QEMU" -fda "$BOOT_BIN" -boot a -m 64M $DISPLAY_OPT $SERIAL_OPT

