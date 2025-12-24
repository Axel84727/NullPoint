#!/usr/bin/env bash
set -euo pipefail

# Usage: build_floppy.sh <output_bin> <boot_src> <stage2_src> <nasm>
OUT="$1"
BOOT_SRC="$2"
STAGE2_SRC="$3"
NASM_BIN="${4:-nasm}"

BUILD_DIR=$(dirname "$OUT")
mkdir -p "$BUILD_DIR"
TMP_BOOT="${OUT}.boot.tmp"
TMP_STAGE2="${OUT}.stage2.tmp"

# Assemble boot
echo "Assembling boot: $BOOT_SRC -> $TMP_BOOT"
"$NASM_BIN" -f bin "$BOOT_SRC" -o "$TMP_BOOT"

# Pad boot to 512 bytes and add signature using existing pad_boot.sh
"$(dirname "$0")/pad_boot.sh" "$OUT" "$TMP_BOOT"

# Assemble stage2
echo "Assembling stage2: $STAGE2_SRC -> $TMP_STAGE2"
"$NASM_BIN" -f bin "$STAGE2_SRC" -o "$TMP_STAGE2"

# Create a 1.44MB floppy image with boot already in place; then write stage2 starting at sector 2
truncate -s 1440K "${OUT}"
# write boot (already padded) to start of image
dd if="$OUT" of="$OUT" bs=512 count=1 conv=notrunc 2>/dev/null || true
# write stage2 at sector 2 (seek=1)
dd if="$TMP_STAGE2" of="$OUT" bs=512 seek=1 conv=notrunc

# Clean tmp files
rm -f "$TMP_BOOT" "$TMP_STAGE2"

echo "Created floppy image: $OUT"

