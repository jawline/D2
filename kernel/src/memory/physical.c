#include <memory/physical.h>
#include <util/kterm.h>

typedef struct __attribute__ ((__packed__)) {
    uint64_t address;
    uint64_t length;
    uint32_t type;
    uint32_t extended; //Probably unused
} smap_entry_t;

uint8_t physical_mem_init(void* smap) {
    
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
