#ifndef _TYPES_DEF_H
#define _TYPES_DEF_H

typedef signed int int64_t __attribute__((__mode__(__DI__)));
typedef unsigned int uint64_t __attribute__((__mode__(__DI__)));

typedef signed int int32_t __attribute__((__mode__(__SI__)));
typedef unsigned int uint32_t __attribute__((__mode__(__SI__)));

typedef signed int int16_t __attribute__((__mode__(__HI__)));
typedef unsigned int uint16_t __attribute__((__mode__(__HI__)));

typedef signed int int8_t __attribute__((__mode__(__QI__)));
typedef unsigned int uint8_t __attribute__((__mode__(__QI__)));

typedef uint64_t size_t;
#define SIZE_MAX 9223372036854775807

#endif
