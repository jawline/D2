#include <util/fprints.h>

void fprints(str_t* dst, str_t const* fmt, ...) {
//    va_list args;
    size_t dst_i = 0;

//    va_start(args, fmt);

    for (size_t i = 0; i < strlen(fmt); i++) {
        strat(dst, i) = strat(fmt, i); 
    }

//    va_end(args);

    dst->len = strlen(fmt);

//    *dst = *conststr("HI\n"); //*strslice(dst, strlen(dst));
}
