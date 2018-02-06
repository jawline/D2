#include <core/screen.h>
#include <core/halt.h>

void kernel_enter(void* mboot, int stack_ptr) { 

    char* foff = 0xDEADBAD;

    clear_screen(); 
    halt();
}
