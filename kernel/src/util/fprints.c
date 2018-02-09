#include <util/fprints.h>

str_t* fprints(str_t* dst, str_t* fmt, ...) {
    va_list args;
    size_t dst_i = 0;

//    va_start(args, fmt);

    for (size_t i = 0; i < strlen(fmt) && dst_i < strlen(dst); i++) {
        if (strat(fmt, i) == '%') {
            strat(dst, dst_i++) = 'E';
            i += 1;
        } else {
            strat(dst, dst_i++) = strat(fmt, i);
        }
    }

//    va_end(args);

    return strslice(dst, 0, dst_i);
}
