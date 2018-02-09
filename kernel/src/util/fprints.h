#ifndef _FORMATTED_PRINT_STRING_H
#define _FORMATTED_PRINT_STRING_H
#include <core/types.h>
#include <core/string.h>
#include <util/stdargs.h>

void fprints(str_t* dst, str_t const* fmt, ...);

#endif
