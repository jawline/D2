#ifndef _PHYSICAL_MEMORY_DEF_H
#define _PHYSICAL_MEMORY_DEF_H

const size_t physical_page_size;

/**
 * Initialize the physical memory manager with boot memory layout
 */
void physical_memory_init(void* layout);

/**
 * Request a free physical address to be mapped to memory
 */
void* physical_memory_get();

/**
 * Return a previously mapped address so that it can be reallocated
 */
void physical_memory_return(void* address);

#endif
