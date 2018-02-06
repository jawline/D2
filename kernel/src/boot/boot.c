#include <core/screen.h>
#include <core/halt.h>

void kernel_enter(void* mboot, int stack_ptr) { 

      clear_screen(); 

      terminal_t current_terminal;
      
      screen_mk_term(&current_terminal);
      terminal_print(&current_terminal, "OK.\n");

      halt();
}
