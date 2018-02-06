#ifndef _SCREEN_DEF_H_
#define _SCREEN_DEF_H_
#include <core/types.h>
#include <core/terminal.h>

void enable_cursor();
void disable_cursor();
void update_cursor(uint8_t, uint8_t);
void clear_screen();

void screen_mk_term(terminal_t*);

#endif //_SCREEN_DEF_H_
