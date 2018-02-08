#ifndef _STRING_DEF_H
#define _STRING_DEF_H
#include <core/types.h>

typedef struct str {
    size_t len;
    uint8_t* data;
} str_t;

#define conststr(x) (str_t) { sizeof(x), x }
#define strlen(x) x->len
#define cstr(x) x->data

#endif //_STRING_DEF_H
