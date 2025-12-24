#!/usr/bin/env bash
set -euo pipefail

# setup.sh - instalar dependencias necesarias en macOS usando Homebrew
# Uso: ./setup.sh

echo "Comprobando Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  cat <<'EOF'
Homebrew no está instalado. Instálalo con:

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Una vez instalado, reejecuta este script.
EOF
  exit 1
fi

echo "Actualizando Homebrew..."
brew update

PACKAGES=(qemu nasm llvm binutils gdb make)

echo "Instalando: ${PACKAGES[*]}"
brew install "${PACKAGES[@]}"

BREW_PREFIX=$(brew --prefix)
# On Apple Silicon Homebrew path is /opt/homebrew, on Intel /usr/local
LLVM_BIN="${BREW_PREFIX}/opt/llvm/bin"

cat <<EOF

Instalación completada. Para usar clang/llvm de Homebrew en esta sesión, añade:

  export PATH=\"${LLVM_BIN}:\$PATH\"

Si usas Apple Silicon y quieres usar hvf aceleración en QEMU, puedes ejecutar QEMU con
  -machine accel=hvf

Firmado de gdb (manual):
  1) Abrir Keychain Access -> Certificate Assistant -> Create a Certificate
     - Name: gdb-cert
     - Identity Type: Self Signed Root
     - Type: Code Signing
     - Create and set to "Always Trust"
  2) Firmar gdb:
     sudo codesign -s gdb-cert $(which gdb)
  3) Verificar:
     codesign -vvv $(which gdb)

Luego compila y ejecuta:
  make -C kernel
  make -C kernel run

Para depurar (en otra terminal):
  make -C kernel gdb

EOF

