#include <core/screen.h>
#include <core/io.h>
#include <core/memory.h>

char const* screen_ptr = (char*) 0xB8000;

uint8_t screen_width() { return 80; }
uint8_t screen_height() { return 25; }

typedef struct {
    uint8_t x;
    uint8_t y;
} screen_term_addt;

screen_term_addt term_addt;

void enable_cursor() {
	outb(0x3D4, 0x0A);
	outb(0x3D5, (inb(0x3D5) & 0xC0) | 1);

	outb(0x3D4, 0x0B);
	outb(0x3D5, (inb(0x3E0) & 0xE0) | 1);
}

void disable_cursor() {
	outb(0x3D4, 0x0A);
	outb(0x3D5, 0x20);
}

void update_cursor(uint8_t x, uint8_t y) {
	uint16_t pos = y * screen_width() + x;
	outb(0x3D4, 0x0F);
	outb(0x3D5, (uint8_t) (pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (uint8_t) ((pos >> 8) & 0xFF));
}

void set_character(uint8_t x, uint8_t y, char c, char a) {
    char* screen = screen_ptr + ((y * screen_width()) + x) * 2;
    *screen++ = c;
    *screen = a;
}

void clear_screen() {
    
    for (int x = 0; x < screen_width(); x++) {
        for (int y = 0; y < screen_height(); y++) {
            set_character(x, y, 0, 0x5);
        }
    }

    update_cursor(0, 0);
}

void screen_term_newline(screen_term_addt* addt) {
    addt->y++;
    addt->x = 0;

    if (addt->y == screen_height()) {
        //TODO: Scroll the screen
        addt->y = 0;
    } 
}

void screen_putc(terminal_t* terminal, uint8_t c) {
    screen_term_addt* addt = (screen_term_addt*) terminal->data;

    if (c == '\n' || c == '\r') {
        screen_term_newline(addt);
        return;
    } else {
        set_character(addt->x++, addt->y, c, 5);
    }

    if (addt->x == screen_width()) {
        screen_term_newline(addt);
    }

    update_cursor(addt->x, addt->y);
}

void screen_mk_term(terminal_t* term) {
    memset(term, 0, sizeof(terminal_t));
    term->putc = screen_putc;
    term->data = &term_addt;
    update_cursor(0, 0);
}
