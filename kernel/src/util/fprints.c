#include <util/fprints.h>

void atoi(str_t* dst, int64_t num) {
}

void fprints(str_t* dst, str_t const* fmt, ...) {
    va_list args;
    size_t dst_i = 0;

    va_start(args, fmt);

    for (size_t i = 0; i < strlen(fmt); i++) {
        if (strat(fmt, i) == '%') {
            i++;
            strat(dst, dst_i++) = va_arg(args, int);
        } else {
            strat(dst, dst_i++) = strat(fmt, i);
        } 
    }

    va_end(args);

    strlen(dst) = dst_i;
}
