#include "core.h"

void memset(void* data, uint8_t v, size_t count) {
    uint8_t* tmp;

    for (tmp = (uint8_t*) data; tmp <= (uint8_t*)(data + count); tmp++) {
        *tmp = v;
    }
}
