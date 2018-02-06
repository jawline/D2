#include <core/screen.h>
#include <core/io.h>

uint8_t screen_width() { return 80; }
uint8_t screen_height() { return 25; }

void enable_cursor() {
	outb(0x3D4, 0x0A);
	outb(0x3D5, (inb(0x3D5) & 0xC0) | 1);

	outb(0x3D4, 0x0B);
	outb(0x3D5, (inb(0x3E0) & 0xE0) | 2);
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
    char* screen = 0xB8000 + ((y * screen_width()) + x) * 2;
    *screen++ = c;
    *screen = a;
}

void clear_screen() {
    for (int x = 0; x < screen_width(); x++) {
        for (int y = 0; y < screen_height(); y++) {
            set_character(x, y, 0, 0x5);
        }
    }

    //disable_cursor();
    update_cursor(0, 0); 
}

void screen_putc(terminal_t* terminal, char c) {
    set_character(0, 0, c, 5);
}

terminal_t screen_mk_term() {
    terminal_t new_term;
    new_term.putc = screen_putc;
    return new_term;
}
