#ifndef _IO_DEVICE_DEF_H
#define _IO_DEVICE_DEF_H
#include <core/types.h>
#include <core/string.h>

typedef struct device {
    size_t (*write) (struct device*, uint8_t const* data, size_t size);
    size_t (*read) (struct device*, uint8_t* data, size_t size);
    void* data; /* Can be used to carry additional data for the device */
} device_t;

void device_write_str(device_t* dev, str_t const* data);

#endif
