#include "../include/vga.h"
#include <stdint.h>

/* Minimal implementation: write to 0xB8000 assuming linear addressing.
 * Note: In 16-bit real mode this may not work; it's intended for protected
 * mode or environments that map 0xB8000 into the linear address space.
 */

void vga_putc_at(char c, uint8_t attr, unsigned row, unsigned col) {
    volatile uint16_t *buffer = (volatile uint16_t *)0xB8000;
    unsigned index = row * 80 + col;
    buffer[index] = ((uint16_t)attr << 8) | (uint8_t)c;
}

/* Write a NUL-terminated string on row 0 starting at column 0 with bright white */
void vga_puts(const char *s) {
    unsigned col = 0;
    while (*s) {
        vga_putc_at(*s++, 0x0F, 0, col++);
    }
}

/* Write a NUL-terminated string at given row/col with attribute */
void vga_puts_at(const char *s, uint8_t attr, unsigned row, unsigned col) {
    while (*s) {
        vga_putc_at(*s++, attr, row, col++);
    }
}
