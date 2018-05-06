#include <memory/physical.h>
#include <util/kterm.h>

uint8_t physical_memory_init(smap_entry_t* smap) {
    
    smap_entry_t* cur = (smap_entry_t*) smap;

    for (; cur->address || cur->length; cur += 1) {
        if (cur->type) {
            char buf[2048];
            str_t* b1 = strbuf(buf, 2048);
            fprints(b1, conststr("Usable Memory %x\n"), cur->address);
            kputln(b1);
        }
    }

    return 0;
}
