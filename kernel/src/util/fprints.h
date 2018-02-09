#ifndef _FORMATTED_PRINT_STRING_H
#define _FORMATTED_PRINT_STRING_H
#include <core/types.h>
#include <core/string.h>
#include <util/stdargs.h>

str_t* fprints(str_t* dst, str_t* fmt, ...);

#endif
