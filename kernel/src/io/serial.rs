use io::outb;
use io::stream::OutStream;

pub struct Serial {
    port: u32
}

pub const SERIAL_PORT: u32 = 0x3F8;

impl Serial {
    pub fn new(port: u32) -> Serial {

        unsafe {
            outb(port + 1, 0x00);    // Disable all interrupts
            outb(port + 3, 0x80);    // Enable DLAB (set baud rate divisor)
            outb(port + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
            outb(port + 1, 0x00);    //                  (hi byte)
            outb(port + 3, 0x03);    // 8 bits, no parity, one stop bit
            outb(port + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
            outb(port + 4, 0x0B);    // IRQs enabled, RTS/DSR setv
        }

        Serial {
            port: port
        }
    }
}

impl OutStream for Serial {
    fn putc(&self, c: u8) {
        unsafe { outb(self.port, c); }
    }
}
