; Minimal stage2 for NULLPOINT
; Assembled for 16-bit real mode, loaded at 0x0000:0x8000
BITS 16
org 0x8000

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Print message to screen and serial
    mov si, msg2
.print2:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    ; serial
    push ax
    mov al, [si-1]
    call serial_putc
    pop ax
    jmp .print2
.done:

    mov si, crlf
.print_crlf:
    lodsb
    cmp al, 0
    je .wait_key
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    ; serial
    push ax
    mov al, [si-1]
    call serial_putc
    pop ax
    jmp .print_crlf

; Wait for a key press (BIOS INT 16h AH=0)
.wait_key:
    mov ah, 0x00
    int 0x16

    ; print confirmation
    mov si, key_msg
.print_key:
    lodsb
    cmp al, 0
    je .hang
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    ; serial
    push ax
    mov al, [si-1]
    call serial_putc
    pop ax
    jmp .print_key

.hang:
    hlt
    jmp .hang

key_msg db "key pressed.",0

; simple serial_putc (same ports as bootloader)
serial_putc:
    push ax
    mov dx, 0x3FD
.waits:
    in al, dx
    test al, 0x20
    jz .waits
    pop ax
    mov dx, 0x3F8
    out dx, al
    ret

msg2 db "stage2 loaded.", 0
crlf db 0x0D,0x0A,0

; pad to 2048 bytes so it fills 4 sectors (optional)
times 2048 - ($ - $$) db 0

