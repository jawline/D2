#ifndef _FORMATTED_PRINT_STRING_H
#define _FORMATTED_PRINT_STRING_H
#include <stdint.h>
#include <core/string.h>
#include <stdarg.h>

void fprints(str_t* dst, str_t const* fmt, ...);

#endif
