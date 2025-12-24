// English comments: write a small red "Hello, World" to VGA text mode (0xB8000)
#include <stdint.h>

static inline void io_halt(void) {
    asm volatile ("hlt");
}

// Write a single character with attribute to VGA text buffer
static inline void vga_putc_at(char c, uint8_t attr, int row, int col) {
    volatile uint16_t *vga = (volatile uint16_t *)0xB8000;
    int idx = row * 80 + col;
    uint16_t entry = ((uint16_t)attr << 8) | (uint8_t)c;
    vga[idx] = entry;
}

void kernel_main(void) {
    // Red on black attribute: foreground=red (0x4), background=black (0x0)
    uint8_t red_attr = 0x04;

    const char *msg = "Hello, World";
    int len = 0;
    while (msg[len]) ++len;

    // choose a position roughly centered (row 12, column ~ (80 - len)/2)
    int row = 12;
    int col = (80 - len) / 2;
    for (int i = 0; i < len; ++i) {
        vga_putc_at(msg[i], red_attr, row, col + i);
    }

    // keep the CPU halted
    for (;;) io_halt();
}
