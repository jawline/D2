#ifndef _STRING_DEF_H
#define _STRING_DEF_H
#include <core/types.h>

typedef struct str {
    size_t len;
    char* data;
} str_t;

#define strbuf(x, i) &((str_t) { sizeof(i), x })
#define conststr(x) &((str_t) { sizeof(x) - 1, x })
#define strlen(x) x->len
#define strat(x, i) x->data[i]
#define cstr(x) x->data

#define strhead(x, i) &((str_t) { i, cstr(x) })
#define strtail(x, i) &((str_t) { strlen(x) - i, cstr(x) + i })
#define strslice(x, i, j) &((str_t) { j - i, cstr(x) + i })

#endif //_STRING_DEF_H
