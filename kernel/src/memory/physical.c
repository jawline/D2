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
        kputln(conststr("Counted Memory Region"));
    }

    kputln(conststr("Done counting"));

    return 0;
}
