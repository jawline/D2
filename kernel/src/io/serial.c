#include <io/serial.h>
#include <io/gpio.h>

const size_t com1 = 0x3F8;

uint8_t serial_init(serial_interface_t* iface) {
    iface->port = com1;

    outb(iface->port + 1, 0x00);    // Disable all interrupts
    outb(iface->port + 3, 0x80);    // Enable DLAB (set baud rate divisor)
    outb(iface->port + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
    outb(iface->port + 1, 0x00);    //                  (hi byte)
    outb(iface->port + 3, 0x03);    // 8 bits, no parity, one stop bit
    outb(iface->port + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
    outb(iface->port + 4, 0x0B);    // IRQs enabled, RTS/DSR setv

    return 1;
}

void serial_putc(serial_interface_t* iface, uint8_t c) {
    outb(iface->port, c);
}

uint8_t serial_is_data(serial_interface_t* iface) {
    return inb(iface->port + 5) & 1;
}

uint8_t serial_getc(serial_interface_t* iface) {
    return serial_is_data(iface) ? inb(iface->port) : 0;
}
