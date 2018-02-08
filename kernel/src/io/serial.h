#ifndef _SERIAL_DEF_H
#define _SERIAL_DEF_H
#include <io/device.h>
#include <core/types.h>

typedef struct {
       size_t port;
} serial_interface_t;

uint8_t serial_init(serial_interface_t* iface);
void serial_putc(serial_interface_t* iface, uint8_t c);
uint8_t serial_getc(serial_interface_t* iface);

uint8_t serial_mk_device(device_t* d, serial_interface_t* iface);

#endif //_SERIAL_DEF_H
