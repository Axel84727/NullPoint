cmake_minimum_required(VERSION 3.10)
project(NullPoint LANGUAGES NONE)

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
set(BOOT_SRC ${CMAKE_SOURCE_DIR}/src/boot.asm)
set(BUILD_DIR ${CMAKE_BINARY_DIR})
set(BOOT_BIN ${BUILD_DIR}/nullpoint.bin)
set(NASM_EXECUTABLE nasm)
set(QEMU_EXECUTABLE qemu-system-x86_64)

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
find_program(NASM ${NASM_EXECUTABLE})
if(NOT NASM)
  message(WARNING "NASM not found in PATH. The build target will still be generated but assembly will fail until nasm is installed.")
endif()

find_program(QEMU ${QEMU_EXECUTABLE})
if(NOT QEMU)
  message(STATUS "QEMU not found. 'run' and 'debug' targets will warn if used.")
endif()

# -----------------------------------------------------------------------------
# Build step: assemble and pad to 512 bytes with 0x55AA signature
# -----------------------------------------------------------------------------
add_custom_command(
  OUTPUT ${BOOT_BIN}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${BUILD_DIR}
  COMMAND ${CMAKE_COMMAND} -E echo "Assembling ${BOOT_SRC} -> ${BOOT_BIN}"
  COMMAND ${CMAKE_COMMAND} -E env ${NASM} -f bin "${BOOT_SRC}" -o "${BOOT_BIN}.tmp"
  COMMAND ${CMAKE_COMMAND} -E env bash "${CMAKE_SOURCE_DIR}/cmake/pad_boot.sh" "${BOOT_BIN}" "${BOOT_BIN}.tmp"
  DEPENDS ${BOOT_SRC}
  COMMENT "Assemble and create ${BOOT_BIN} (512 bytes, 0x55AA signature)"
  VERBATIM
)

add_custom_target(boot ALL DEPENDS ${BOOT_BIN})

# -----------------------------------------------------------------------------
# run target: use QEMU to boot the binary image
# -----------------------------------------------------------------------------
add_custom_target(run
  COMMAND ${CMAKE_COMMAND} -E echo "Running NullPoint in QEMU..."
  COMMAND ${CMAKE_COMMAND} -E env bash -c "if command -v ${QEMU_EXECUTABLE} >/dev/null 2>&1; then ${QEMU_EXECUTABLE} -drive format=raw,file='${BOOT_BIN}',if=floppy -serial stdio -no-reboot; else echo 'QEMU not found. Install qemu-system-x86_64 to run.'; fi"
  DEPENDS boot
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

# -----------------------------------------------------------------------------
# debug target: start QEMU with gdbserver (-S -gdb tcp::1234)
# -----------------------------------------------------------------------------
add_custom_target(debug
  COMMAND ${CMAKE_COMMAND} -E echo "Starting QEMU with gdb server on tcp:1234..."
  COMMAND ${CMAKE_COMMAND} -E env bash -c "if command -v ${QEMU_EXECUTABLE} >/dev/null 2>&1; then ${QEMU_EXECUTABLE} -drive format=raw,file='${BOOT_BIN}',if=floppy -serial stdio -S -gdb tcp::1234; else echo 'QEMU not found. Install qemu-system-x86_64 to debug.'; fi"
  DEPENDS boot
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

# -----------------------------------------------------------------------------
# Useful information
# -----------------------------------------------------------------------------
message(STATUS "NullPoint project configured. Use: cmake -S . -B build && cmake --build build --target boot")
message(STATUS "Run image: cmake --build build --target run")
message(STATUS "Debug image: cmake --build build --target debug")
