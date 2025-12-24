// English: write a small red "Hello, World" to VGA text mode (0xB8000) and also send it to serial (COM1)
#include <stdint.h>

static inline void io_halt(void) {
    asm volatile ("hlt");
}

static inline void outb(uint16_t port, uint8_t val) {
    asm volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// Initialize serial port COM1 at 115200 baud
static void serial_init(void) {
    const uint16_t port = 0x3F8;
    // disable interrupts
    outb(port + 1, 0x00);
    // enable DLAB (set baud rate divisor)
    outb(port + 3, 0x80);
    // set divisor to 1 (115200 baud)
    outb(port + 0, 0x01);
    outb(port + 1, 0x00);
    // 8 bits, no parity, one stop bit
    outb(port + 3, 0x03);
    // enable FIFO, clear them
    outb(port + 2, 0xC7);
    // IRQs enabled, RTS/DSR set
    outb(port + 4, 0x0B);
}

// Write a single character with attribute to VGA text buffer
static inline void vga_putc_at(char c, uint8_t attr, int row, int col) {
    volatile uint16_t *vga = (volatile uint16_t *)0xB8000;
    int idx = row * 80 + col;
    uint16_t entry = ((uint16_t)attr << 8) | (uint8_t)c;
    vga[idx] = entry;
}

// Simple serial write to COM1 (0x3f8)
static void serial_write_char(char c) {
    outb(0x3f8, (uint8_t)c);
}

static void serial_write_str(const char *s) {
    for (const char *p = s; *p; ++p) serial_write_char(*p);
}

void kernel_main(void) {
    const char *msg = "Hello, World\n";

    // VGA: red text (foreground=red=0x4)
    uint8_t red_attr = 0x04;
    int len = 0;
    while (msg[len]) ++len;
    int row = 12;
    int col = (80 - (len-1)) / 2; // subtract newline
    for (int i = 0; i < len-1; ++i) {
        vga_putc_at(msg[i], red_attr, row, col + i);
    }

    // Serial: initialize then send the same message so headless QEMU shows it
    serial_init();
    serial_write_str(msg);

    for (;;) io_halt();
}
