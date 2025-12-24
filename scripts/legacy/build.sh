#!/usr/bin/env bash
# @brief Build NullPoint project using CMake (configure + build)
# Usage: ./scripts/build.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"

mkdir -p "${BUILD_DIR}"
cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}"
cmake --build "${BUILD_DIR}" --target boot

echo "Build complete. Output: ${BUILD_DIR}/nullpoint.bin"
