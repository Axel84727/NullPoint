#!/usr/bin/env bash
# Convenience aliases for NullPoint development.
# Source this file to add the aliases to your shell session:
#   source scripts/aliases.sh

# Build the boot image (uses the helper script)
alias np-build='./scripts/build_boot.sh'

# Run the built image in QEMU with Cocoa GUI and serial to stdio
alias np-run='qemu-system-i386 -fda build/nullpoint.bin -boot a -m 64M -display cocoa -serial stdio'

# Alternative run (headless, terminal-only)
alias np-run-nographic='qemu-system-i386 -fda build/nullpoint.bin -boot a -m 64M -nographic -serial stdio'

# Helpful note when sourcing interactively
if [ "$PS1" ]; then
  echo "NullPoint aliases loaded: np-build, np-run, np-run-nographic"
fi

