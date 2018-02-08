#include <core/screen.h>
#include <core/halt.h>
#include <core/string.h>
#include <io/device.h>
#include <io/serial.h>

void kernel_enter(void* smap) { 

      clear_screen(); 

      terminal_t current_terminal;
      
      screen_mk_term(&current_terminal);
      terminal_print(&current_terminal, "OK.\n");

      serial_interface_t com1;
      device_t dev1;

      if (!serial_init(&com1) || !serial_mk_device(&dev1, &com1)) {
        terminal_print(&current_terminal, "KERROR\n");
      }

      device_write_str(&dev1, &conststr("Hello!\n"));
      device_write_str(&dev1, &conststr("Whats up\n"));

      halt();
}
