#ifndef _TERMINAL_DEF_H
#define _TERMINAL_DEF_H
#include <core/types.h>
#include <io/device.h>

typedef struct terminal {
    void (*puts) (struct terminal*, str_t const*);
    void* data; /* Can be used to carry additional data for the terminal */
} terminal_t;

void terminal_puts(terminal_t*, str_t const*);
void terminal_putln(terminal_t* t, str_t const* s);

/**
 * Create a terminal from an IO device
 */

void terminal_from_device(terminal_t*, device_t*);

#endif //_TERMINAL_DEF_H
