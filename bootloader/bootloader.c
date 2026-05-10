// bootloader.c
// Standard libraries are not available, so they have to be purely implemented

#include "bootloader.h"

#define VGA_BASE ((volatile uint16_t *)0xB8000)
#define VGA_COLS 80
#define VGA_ROWS 25

#define COLOR_WHITE_ON_BLACK  0x07
#define COLOR_GREEN_ON_BLACK  0x0A
#define COLOR_CYAN_ON_BLACK   0x0B
#define COLOR_YELLOW_ON_BLACK 0x0E
#define COLOR_WHITE_ON_BLUE   0x1F

static inline void outb(uint16_t port, uint8_t val)
{
    __asm__ volatile (
        "outb %0, %1" :: "a"(val), "Nd"(port)
    );
}

// Global variables
static int cursor_row = 0;
static int cursor_col = 0;
static uint8_t current_color = COLOR_WHITE_ON_BLACK;

static void update_cursor(void)
{
    uint16_t pos = cursor_row * VGA_COLS + cursor_col;
    outb(0x3D4, 0x0F);
    outb(0x3D5, (uint8_t)(pos & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));
}

static void scroll(void)
{
    volatile uint16_t *vga = VGA_BASE;

    for (int row = 0; row < VGA_ROWS - 1; row++)
        for (int col = 0; col < VGA_COLS; col++)
            vga[row * VGA_COLS + col] = vga[(row + 1) * VGA_COLS + col];

    uint16_t blank = ' ' | ((uint16_t)current_color << 8);
    for (int col = 0; col < VGA_COLS; col++)
        vga[(VGA_ROWS - 1) * VGA_COLS + col] = blank;
    cursor_row = VGA_ROWS - 1;
}

static void itoa(uint32_t n, char *buf, int base)
{
    const char digits[] = "0123456789ABCDEF";
    char tmp[32];
    int i = 0;
    if (n == 0)
    {
        buf[0] = '0';
        buf[1] = '\0';
        return;
    }

    while (n > 0)
    {
        tmp[i++] = digits[n % base];
        n /= base;
    }

    int j = 0;
    while (i > 0)
        buf[j++] = tmp[--i];

    buf[j] = '\0';
}

void vga_clear(void)
{
    volatile uint16_t *vga = VGA_BASE;
    uint16_t blank = ' ' | (COLOR_WHITE_ON_BLACK << 8);
    for (int i = 0; i < VGA_COLS * VGA_ROWS; i++)
        vga[i] = blank;
    cursor_row = cursor_col = 0;
    update_cursor();
}

void vga_putchar(char c)
{
    
}

void vga_puts(const char *s)
{

}

void vga_set_color(uint8_t color)
{

}

void vga_put_dec(uint32_t n)
{

}

void vga_put_hex(uint32_t n)
{

}

void bootloader_main(uint32_t boot_drive)
{

}