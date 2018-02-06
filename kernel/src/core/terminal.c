#include <core/terminal.h>

void print_string(terminal_t* term, char const* st) {
    for (; *st; st++) {
        term->putc(term, *st);
    }
}
