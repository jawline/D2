#include <core/screen.h>
#include <core/halt.h>
#include <core/string.h>
#include <io/device.h>
#include <io/serial.h>
#include <util/kterm.h>
#include <util/fprints.h>
#include <memory/physical.h>

void init_kterm() {
    clear_screen();
    if (!screen_mk_term(kterm_get())) {
        //TODO: Panic with no screen!?
    }
}

void kernel_enter(void* smap) {  
      init_kterm();

      char buf[2048];
      str_t* b1 = strbuf(buf, 2048);
      fprints(b1, conststr("Hello %i\n"), 0);
      kputln(b1);

      halt();

      kputln(conststr("OK."));
      
      if (!physical_mem_init(smap)) {
        kpanic(conststr("PHYS INIT FAIL."));
      }

      kputln(conststr("MEM OK."));


      halt();
}
