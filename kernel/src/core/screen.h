#ifndef _SCREEN_DEF_H_
#define _SCREEN_DEF_H_
#include <core/types.h>
#include <core/terminal.h>

void enable_cursor();
void disable_cursor();
void update_cursor(uint8_t, uint8_t);

terminal_t screen_mk_term();
void clear_screen();

#endif //_SCREEN_DEF_H_
