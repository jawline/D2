#include <util/fprints.h>
#include <util/strhelpers.h>
#include <stdarg.h>

void fprints(str_t* dst, str_t const* fmt, ...) {
    va_list args;
    size_t dst_i = 0;

    va_start(args, fmt);

    for (size_t i = 0; i < strlen(fmt); i++) {
        if (strat(fmt, i) == '%') {
            
            if (strat(fmt, i + 1) == 'i') {
                str_t* v_dst = strtail(dst, dst_i);
                itoa(v_dst, 500, 10);
                dst_i += strlen(v_dst);
            }

            i++;
        } else {
            strat(dst, dst_i++) = strat(fmt, i);
        } 
    }

    va_end(args);

    strlen(dst) = dst_i;
}
