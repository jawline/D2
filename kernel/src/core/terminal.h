#ifndef _TERMINAL_DEF_H
#define _TERMINAL_DEF_H
#include <core/types.h>

typedef struct terminal {
    void (*putc) (struct terminal*, uint8_t);
    void* data; /* Can be used to carry additional data for the terminal */
} terminal_t;

/*
 * Write given string to the terminal
 */

void terminal_print(terminal_t*, char const*);

#endif //_TERMINAL_DEF_H
