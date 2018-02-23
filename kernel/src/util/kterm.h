#ifndef _KTERM_DEF_H
#define _KTERM_DEF_H
#include <core/string.h>
#include <core/terminal.h>

terminal_t* kterm_get();

void kputs(str_t* t);
void kputln(str_t* t);
void kpanic(str_t* t);

#endif
