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

    ; The greeting is shown only after a key press

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

    ; After a key is pressed, clear text and show greeting
    call write_hello_world_top_right

    ; Halt here
    jmp .hang

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

; --- VGA text helper ---
; write_hello_world_top_right: clear the text buffer (80x25) with spaces (attr 0x07)
; then write the string "hello world" in bright red (attr 0x0C) at row 0, column 69
; preserves AX, CX, DI, ES
write_hello_world_top_right:
    push ax
    push cx
    push di
    push es

    mov ax, 0xB800
    mov es, ax

    xor di, di        ; start at offset 0
    mov cx, 2000      ; 80*25 = 2000 cells (stosw counts words)
    mov ax, 0x0720    ; word: AH=attr(0x07), AL=' ' (0x20)
    rep stosw         ; fill screen with space + attribute

    ; compute starting cell for row 0, column 69 (80 columns total)
    mov di, 69
    shl di, 1         ; cell index * 2 -> byte offset for ES:DI addressing

    ; write NUL-terminated message from data
    mov si, hello_msg
.write_loop:
    lodsb
    cmp al, 0
    je .done_write
    mov ah, 0x0C      ; bright red attribute
    stosw
    jmp .write_loop
.done_write:

    pop es
    pop di
    pop cx
    pop ax
    ret

hello_msg db "hello world",0

msg2 db "stage2 loaded.", 0
crlf db 0x0D,0x0A,0

; pad to 2048 bytes so it fills 4 sectors (optional)
times 2048 - ($ - $$) db 0

