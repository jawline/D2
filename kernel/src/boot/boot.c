#include <core/screen.h>
#include <core/halt.h>
#include <core/string.h>

#include <io/device.h>
#include <io/serial.h>

#include <util/kterm.h>
#include <util/fprints.h>

#include <memory/physical.h>
#include <memory/virtual.h>

void init_kterm() {
    clear_screen();
    if (!screen_mk_term(kterm_get())) {
        kpanic(conststr("SCREEN INIT FAIL.")); //TODO: Find a way to report this to the user
    }
}

void kernel_enter(void* smap) {  
      init_kterm();

      kputln(conststr("OK."));
      
      if (!physical_memory_init((smap_entry_t*) smap)) {
        kpanic(conststr("PHYS INIT FAIL."));
      }

      if (!virtual_memory_init()) {
        kpanic(conststr("VIRT INIT FAIL."));
      }

      kputln(conststr("MEM OK."));

      halt();
}
