#include <core/screen.h>
#include <core/halt.h>
#include <core/string.h>
#include <io/device.h>
#include <io/serial.h>
#include <util/kterm.h>
#include <memory/physical.h>

void init_kterm() {
    clear_screen();
    if (!screen_mk_term(kterm_get())) {
        //TODO: Panic with no screen!?
    }
}

void kernel_enter(void* smap) {  
      init_kterm();
      
      kputln(conststr("OK."));
      
      if (!physical_mem_init(smap)) {
        kpanic(conststr("PHYS INIT FAIL."));
      }

      kputln(conststr("MEM OK."));

      halt();
}
