#include <core/screen.h>
#include <core/halt.h>

void kernel_enter(void* mboot, int stack_ptr) { 

    clear_screen(); 

    terminal_t nw = screen_mk_term();
    terminal_print(&nw, "HELLO");

    halt();
}
