#include <util/kterm.h>
#include <core/halt.h>

/**
 * Global terminal used by kputs after being instanciated
 */
terminal_t kterm_instance;

terminal_t* kterm_get() {
    return &kterm_instance;
}

void kputs(str_t* t) {
    terminal_puts(kterm_get(), t);
}

void kputln(str_t* t) {
    terminal_putln(kterm_get(), t);
}

void kpanic(str_t* t) {
    kputs("PANIC: ");
    kputln(t);
    halt();
}

