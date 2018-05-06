#ifndef _PHYSICAL_MEMORY_DEF_H
#define _PHYSICAL_MEMORY_DEF_H
#include <stdint.h>
#include <stddef.h>

typedef struct __attribute__ ((__packed__)) {
    uint64_t address;
    uint64_t length;
    uint32_t type;
    uint32_t extended; //Probably unused
} smap_entry_t;

const size_t physical_page_size;

/**
 * Initialize the physical memory manager with boot memory layout
 */
uint8_t physical_memory_init(smap_entry_t* smap);

/**
 * Request a free physical address to be mapped to memory
 */
void* physical_memory_get();

/**
 * Return a previously mapped address so that it can be reallocated
 */
void physical_memory_return(void* address);

#endif
