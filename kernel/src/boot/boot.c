#include <core/screen.h>
#include <core/halt.h>
#include <io/serial.h>

void kernel_enter(void* mboot, int stack_ptr) { 

      clear_screen(); 

      terminal_t current_terminal;
      
      screen_mk_term(&current_terminal);
      terminal_print(&current_terminal, "OK.\n");

      serial_interface_t com1;
      serial_init(&com1);
      serial_putc(&com1, 'H');

      halt();
}
