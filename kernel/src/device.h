#ifndef _IO_DEVICE_DEF_H
#define _IO_DEVICE_DEF_H

typedef struct {
    size_t (*read) (uint8_t*, size_t, size_t);
    size_t (*write) (uint8_t*, size_t, size_t);
    void* data; /* Can be used to carry additional data for the terminal */
} io_device_t;

#endif
