#include <core/terminal.h>

str_t const* term_newline = conststr("\r\n");

void terminal_device_puts(terminal_t* t, str_t const* str) {
    device_write_str((device_t*) t->data, str);
}

void terminal_from_device(terminal_t* term, device_t* dev) {
    term->puts = terminal_device_puts;
    term->data = dev;
}

void terminal_puts(terminal_t* t, str_t const* s) {
    for (size_t i = 0; i < strlen(s); i++) {
 
        //Rewrite \n to \r\n
        if (strat(s, i) == '\n') {
            t->puts(t, term_newline);
        } else {
            t->puts(t, strslice(s, i, i+1));
        }
    }
}

void terminal_putln(terminal_t* t, str_t const* s) {
    terminal_puts(t, s);
    terminal_puts(t, conststr("\n"));
}
