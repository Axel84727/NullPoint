#!/usr/bin/env bash
# @brief Pad an assembled boot sector to 512 bytes and append the 0x55AA signature.
# Usage: pad_boot.sh <output_bin> <assembled_tmp>
set -euo pipefail

BOOT_BIN="$1"
TMP_BIN="$2"

if [ ! -f "$TMP_BIN" ]; then
  echo "Missing assembled input: $TMP_BIN" >&2
  exit 1
fi

SIZE=$(wc -c < "$TMP_BIN" | tr -d '[:space:]')

if [ "$SIZE" -gt 512 ]; then
  echo "ERROR: assembled file larger than 512 bytes ($SIZE)" >&2
  exit 1
fi

if [ "$SIZE" -eq 512 ]; then
  # Already a full sector. Verify signature (last two bytes == 55 AA)
  if command -v xxd >/dev/null 2>&1; then
    SIG=$(xxd -p -c2 -s 510 "$TMP_BIN" | tr '[:upper:]' '[:lower:]')
  else
    SIG=$(tail -c 2 "$TMP_BIN" | od -An -t x1 | tr -d ' \n' | tr '[:upper:]' '[:lower:]')
  fi
  if [ "$SIG" != "55aa" ]; then
    echo "ERROR: 512-byte assembled file missing boot signature (found: $SIG)" >&2
    exit 1
  fi
  cp "$TMP_BIN" "$BOOT_BIN"
  echo "Copied $TMP_BIN -> $BOOT_BIN (already 512 bytes with signature)"
  exit 0
fi

# At this point size is <= 511
if [ "$SIZE" -gt 510 ]; then
  echo "ERROR: assembled file larger than 510 bytes ($SIZE)" >&2
  exit 1
fi

# Create a 510-byte zero-filled destination
if dd if=/dev/zero of="$BOOT_BIN" bs=1 count=510 conv=notrunc 2>/dev/null; then
  :
else
  truncate -s 510 "$BOOT_BIN" 2>/dev/null || :
fi

# Overwrite from start with assembled bytes (will not truncate the dest file)
if ! dd if="$TMP_BIN" of="$BOOT_BIN" conv=notrunc 2>/dev/null; then
  cat "$TMP_BIN" > "$BOOT_BIN"
fi

# Append boot signature (2 bytes)
printf '\x55\xAA' >> "$BOOT_BIN"

# Final sanity check
FINAL_SIZE=$(wc -c < "$BOOT_BIN" | tr -d '[:space:]')
if [ "$FINAL_SIZE" -ne 512 ]; then
  echo "ERROR: final boot binary size is $FINAL_SIZE (expected 512)" >&2
  exit 1
fi

echo "Created $BOOT_BIN (512 bytes)"
