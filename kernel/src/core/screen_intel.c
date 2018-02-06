#include <core/screen.h>

void cls() {
    char* screen = 0xB8000;
    for (int i = 0; i < 80 * 25; i++) { *screen = 0; }
}
