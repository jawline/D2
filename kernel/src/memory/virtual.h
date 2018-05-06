#ifndef _VIRTUAL_MEMORY_DEF_H
#define _VIRTUAL_MEMORY_DEF_H
#include <stdint.h>
#include <stddef.h>

uint8_t virtual_memory_init();
void virtual_map_page(void* virtual_page, void* physical_page);

#endif
