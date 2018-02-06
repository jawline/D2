#include <core/screen.h>

extern void halt();

void kernel_enter(void* mboot, int stack_ptr) {
    cls(); 
    halt();
}
