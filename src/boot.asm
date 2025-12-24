; @brief NullPoint boot sector (512 bytes) - NASM
; Minimal, well-documented 16-bit real-mode boot sector.
; @author Axel
; @license MIT
;
; This boot sector is intended for learning. It:
;  - is assembled at origin 0x7C00
;  - clears the screen
;  - sets video mode 3 (80x25 text)
;  - prints a single character using BIOS INT 10h
;  - prints the string "Hello from NULLPOINT" using BIOS INT 10h
;  - ends with the boot signature 0x55AA and is padded to 512 bytes
;
BITS 16
org 0x7C00

start:
    cli                 ; disable interrupts while we set up
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; set up a safe stack (above bootloader)

    ; Clear the screen using BIOS INT 10h, AH=0x06 (scroll up)
    mov ah, 0x06
    xor al, al
    xor bh, bh
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 0x10

    ; Set video mode 3 (80x25 color text)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Print single character 'X' at current cursor using BIOS teletype AH=0x0E
    mov ah, 0x0E
    mov al, 'X'
    mov bh, 0
    mov bl, 0x07
    int 0x10

    ; Print string using BIOS teletype INT 10h AH=0x0E
    lea si, [hello_msg]
.print_loop:
    lodsb
    cmp al, 0
    je .done_print
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .print_loop

.done_print:

.hang:
    hlt
    jmp .hang

; -----------------------------------------------------------------------------
; Data
; -----------------------------------------------------------------------------
hello_msg db "Hello from NULLPOINT", 0

; -----------------------------------------------------------------------------
; Boot signature and padding - final 2 bytes must be 0x55AA (little-endian)
; The build system will also ensure the file is exactly 512 bytes.
; -----------------------------------------------------------------------------

times 510 - ($ - $$) db 0
dw 0xAA55
