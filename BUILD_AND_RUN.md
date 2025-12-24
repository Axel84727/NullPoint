BUILD & RUN (NULLPOINT)

Below are the minimal commands to build and run the bootloader image.

1) Build (using CMake):

```bash
cmake -S . -B build && cmake --build build --target boot
```

2) Run in QEMU (macOS window + serial output to the terminal):

```bash
qemu-system-i386 -fda build/nullpoint.bin -boot a -m 64M -display cocoa -serial stdio
```

Quick notes:
- If you prefer not to use CMake, you can use the simple helper script:

```bash
./scripts/build_boot.sh
```

- Make sure `qemu-system-i386` is installed and available in your PATH. On macOS the display backend used above is `cocoa`.

EOF
