// testing hackatime
// typing some stuff
// this is not code, this is a test
[BITS 32]

global _start

_start:
    cli

.hang:
    hlt
    jmp .hang

