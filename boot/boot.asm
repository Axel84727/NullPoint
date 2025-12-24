; Minimal NULLPOINT boot sector (512 bytes) - NASM
; KISS: Print a message, load a second stage (sectors 2..5) into 0x0000:0x8000, then jump to it.
BITS 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; init serial (COM1)
    call serial_init

    ; Print message via BIOS teletype
    mov si, msg
.print:
    lodsb
    cmp al, 0
    je .done_print
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    ; also send over serial
    push ax
    mov al, [si-1]
    call serial_putc
    pop ax
    jmp .print
.done_print:

    ; also send newline to serial
    mov al, 0x0A
    call serial_putc

    ; Load sectors 2..5 (4 sectors) from drive 0 into 0x0000:0x8000
    mov bx, 0x8000         ; offset
    mov dl, [boot_drive]
    mov dh, 0              ; head
    mov ch, 0              ; track
    mov cl, 2              ; sector (1-based) - start at sector 2
    mov al, 4              ; number of sectors to read
    call load_sectors

    ; Jump to loaded stage2 at 0x0000:0x8000
    jmp 0x0000:0x8000

hang:
    hlt
    jmp hang

; -----------------------------------------------------------------------------
; serial_init: initialize COM1 (0x3F8) 115200/8n1 via divisor
; ports: DATA=0x3F8, IER=0x3F9, LCR=0x3FB
; -----------------------------------------------------------------------------
serial_init:
    ; Set DLAB=1 in LCR (0x3FB)
    mov dx, 0x3FB
    mov al, 0x80
    out dx, al
    ; write divisor low to 0x3F8
    mov dx, 0x3F8
    mov al, 0x01
    out dx, al
    ; write divisor high to 0x3F9
    mov dx, 0x3F9
    mov al, 0x00
    out dx, al
    ; set LCR = 0x03 (8N1)
    mov dx, 0x3FB
    mov al, 0x03
    out dx, al
    ret

; -----------------------------------------------------------------------------
; serial_putc: wait for transmitter empty and send AL to COM1
; Input: AL = char
; -----------------------------------------------------------------------------
serial_putc:
    push ax
    ; poll LSR (0x3FD)
    mov dx, 0x3FD
.wait:
    in al, dx
    test al, 0x20
    jz .wait
    pop ax
    mov dx, 0x3F8
    out dx, al
    ret

; -----------------------------------------------------------------------------
; load_sectors: uses CHS via BIOS INT 13h AH=0x02
; Inputs: DL = drive, CH = track, DH = head, CL = starting sector, AL = count
; ES:BX = destination
; Returns: CF=0 on success
; -----------------------------------------------------------------------------
load_sectors:
    ; preserve registers we clobber (simple)
    push ax
    push bx
    push cx
    push dx

    mov ah, 0x02
    ; AL already has sectors count
    xor ax, ax
    mov es, ax
    mov ax, 0x0000  ; ensure ES=0 (already set) - kept for clarity
    mov ah, 0x02
    int 0x13
    jc .err

    pop dx
    pop cx
    pop bx
    pop ax
    ret
.err:
    pop dx
    pop cx
    pop bx
    pop ax
    ; print error char 'E'
    mov al, 'E'
    mov ah, 0x0E
    int 0x10
    jmp hang

; Data
msg db "NULLPOINT booting...", 0
boot_drive db 0

; Pad to 510 bytes then signature
times 510 - ($ - $$) db 0
dw 0xAA55

