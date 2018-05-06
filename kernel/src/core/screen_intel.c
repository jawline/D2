#include <core/screen.h>
#include <io/gpio.h>
#include <util/core.h>

typedef struct {
    uint8_t x;
    uint8_t y;
} screen_term_addt;

char* const screen_ptr = (char*) 0xB8000;
const uint8_t default_text_attribute = 0x7;

uint8_t screen_width() { return 80; }
uint8_t screen_height() { return 25; }


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
    *screen = c;
    *(screen + 1) = a;
}

void clear_screen() {
    
    for (int x = 0; x < screen_width(); x++) {
        for (int y = 0; y < screen_height(); y++) {
            set_character(x, y, 0, default_text_attribute);
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

    if (c == '\n') {
        screen_term_newline(addt);
    } else if (c == '\r') {
        addt->x = 0; //Reset x position on CR
    } else {
        set_character(addt->x++, addt->y, c, default_text_attribute);
    }

    if (addt->x == screen_width()) {
        screen_term_newline(addt);
    }

    update_cursor(addt->x, addt->y);
}

void screen_puts(terminal_t* term, str_t const* str) {
    for (size_t i = 0; i < strlen(str); i++) {
        screen_putc(term, strat(str, i));
    }
}

uint8_t screen_mk_term(terminal_t* term) {
    memset(term, 0, sizeof(terminal_t));
    term->puts = screen_puts;
    term->data = &term_addt;
    update_cursor(0, 0);
    return 1;
}
