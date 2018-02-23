#include <io/device.h>

void device_write_str(device_t* dev, str_t const* data) {
    dev->write(dev, (uint8_t const*) cstr(data), strlen(data));
}

