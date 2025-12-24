# Real Mode (16-bit) basics

@brief A short primer for the NullPoint boot sector and real mode addressing.

- Real mode uses 16-bit registers and segmented addressing.
- Physical address = (segment << 4) + offset.
- BIOS loads the boot sector at 0x0000:0x7C00 (physical 0x07C00).
- Interrupts: use INT 0x10 for video services (teletype AH=0x0E), INT 0x13 for disk.
- Boot signature: the last two bytes of a 512-byte sector must be 0x55 0xAA.

Stack and memory:
- At boot, DS:SI and other registers are undefined; common pattern clears DS/ES and sets SP.

Debugging with QEMU + gdb:
- Start QEMU with: qemu-system-x86_64 -drive format=raw,file=build/nullpoint.bin -S -gdb tcp::1234
- Connect: gdb -q; set architecture i8086; target remote :1234; break *0x7c00; continue

This document is intentionally short. See comments in `src/boot.asm` for implementation details.

