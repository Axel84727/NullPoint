[org 0x7C00]
[BITS 16]

start:
    cli
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Set video mode 03h (80x25 text)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Clear screen: write space (0x20) with attribute 0x07 (light grey on black)
    mov ax, 0xB800
    mov es, ax
    xor di, di
    mov cx, 2000          ; 80*25
    mov ax, 0x0720        ; attribute 0x07 << 8 | ' '
    rep stosw

    ; Prepare message
    mov si, message
    mov cx, message_len   ; cx = length

    ; compute start column: (80 - cx)/2
    mov ax, 80
    sub ax, cx
    shr ax, 1             ; ax = column
    mov bx, ax            ; bx = column

    ; compute offset = row*80 + col ; choose row 12
    mov ax, 12
    mov dx, 80
    mul dx                ; ax = 12*80
    add ax, bx            ; ax = row*80 + col

    ; convert to byte offset in VGA memory (each cell = 2 bytes)
    shl ax, 1             ; ax = byte offset
    mov di, ax            ; DI = offset

    ; write message characters with attribute 0x0C (light red)
    mov bx, 0x0C          ; attribute
.write_loop:
    mov al, [si]
    cmp al, 0
    je .done
    mov ah, bl            ; AH = attribute
    mov [es:di], ax
    add si, 1
    add di, 2
    jmp .write_loop

.done:
    ; infinite halt
.halt:
    hlt
    jmp .halt

message: db 'Hello from NULLPOINT', 0
message_len: equ $-message

; pad up to 510 bytes, then 0xAA55
times 510-($-$$) db 0
dw 0xAA55
