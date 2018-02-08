#include <io/device.h>

void device_write_str(device_t* dev, str_t* data) {
    dev->write(dev, cstr(data), strlen(data));
}

