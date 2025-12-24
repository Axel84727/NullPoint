#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOOT_SRC="$ROOT_DIR/boot/boot.asm"
STAGE2_SRC="$ROOT_DIR/boot/stage2.asm"
OUT="$ROOT_DIR/build/nullpoint.bin"
NASM_BIN="${NASM:-nasm}"

mkdir -p "$ROOT_DIR/build"

# assemble boot
echo "Assembling $BOOT_SRC"
"$NASM_BIN" -f bin "$BOOT_SRC" -o "$OUT.tmp"
# pad boot to 512 with signature
echo "Padding boot to 512 and adding signature"
"$ROOT_DIR/cmake/pad_boot.sh" "$OUT" "$OUT.tmp"
rm -f "$OUT.tmp"

# assemble stage2
echo "Assembling $STAGE2_SRC"
"$NASM_BIN" -f bin "$STAGE2_SRC" -o "$ROOT_DIR/build/stage2.bin"

# create floppy and write stage2 at sector 2
truncate -s 1440K "$OUT"
dd if="$ROOT_DIR/build/stage2.bin" of="$OUT" bs=512 seek=1 conv=notrunc

# cleanup
rm -f "$ROOT_DIR/build/stage2.bin"

echo "Created $OUT"

