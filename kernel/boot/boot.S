.section .multiboot
    .align 4
    .long 0x1BADB002        # magic
    .long 0x00000000        # flags (0 = no special requests)
    .long -(0x1BADB002 + 0x00000000)  # checksum

.section .text
.globl _start
.globl kernel_main
_start:
    jmp kernel_main
