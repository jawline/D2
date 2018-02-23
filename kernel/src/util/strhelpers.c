#include "strhelpers.h"

/**
 * Return + 0x30 to turn into 0-9 or + 0x41 to turn into A-Z
 */
char to_char(int64_t val) { 
    return val < 10 ? val + 0x30 : val + 0x41;
}

void str_reverse(str_t* dst) {
    for (size_t i = 0; i < strlen(dst) / 2; i++) {
        size_t end_elem = strlen(dst) - i - 1;
        char tmp = strat(dst, end_elem);
        strat(dst, end_elem) = strat(dst, i);
        strat(dst, i) = tmp;
    }
}

uint8_t itoa(str_t* dst, int64_t v, int base) {
   #define PUTC(c) if (i >= strlen(dst)) { return 0; } strat(dst, i++) = c
   size_t i = 0;
   size_t negative = 0;

   //Make v positive if its negative
   if (v < 0) {
       v = -1 * v;
       negative = 1;
   }

   while (v) {
       PUTC(to_char(v % base));
       v = v / base;       
   }

   if (negative) {
       PUTC('-');
   }

   str_reverse(strslice(dst, 0, i));

   #undef PUTC
   strlen(dst) = i; //Update strlen
   return 1;
}
