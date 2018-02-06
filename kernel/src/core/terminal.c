#include <core/terminal.h>

void terminal_print(terminal_t* term, char const* st) {
    for (; *st; st++) {
        term->putc(term, *st);
    }
}
