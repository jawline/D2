#include <io/device.h>

void device_write_str(device_t* dev, str_t* data) {
    dev->write(dev, (uint8_t*) cstr(data), strlen(data));
}

