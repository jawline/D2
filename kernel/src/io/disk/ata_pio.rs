use core::mem;
use io::{outb, inb, inw};

const MASTER: u8 = 0xE0;
pub const ROOT_PORT: u16 = 0x1F0;

pub struct ATAPIO {
    port: u16,
    master: bool
}

/**
 * 28 bit ATA PIO Polling implementation
 * For the most basic file system access
 */
impl ATAPIO {

    pub fn new(port: u16, master: bool) -> ATAPIO {
        ATAPIO {
            port: port,
            master: master
        }
    }

    pub fn read(&self, sector: u32, count: u8, dst: &mut [u8]) {
        let sector = sector & 0x00FFFFFF;
        let slave_bit = if self.master { 1 } else { 0 };
        let mut dst_idx = 0;

        unsafe {

            let dst: &mut [u16] = mem::transmute(dst); 

            outb(self.port + 6, (MASTER | (slave_bit << 4)) | (sector >> 24 & 0x0F) as u8); //Send slave or master with the upper 4 bits to the final port
            outb(self.port + 1, 0); //Null to root port
            outb(self.port + 2, count); //Send the sector count
            outb(self.port + 3, (sector & 0xFF) as u8); //Lower 8 bits
            outb(self.port + 4, ((sector >> 8) & 0xFF) as u8); //Middle 8 bits
            outb(self.port + 5, ((sector >> 16) & 0xFF) as u8); //16-24 bits
            outb(self.port + 7, 0x20); //READ SECTORS command

            for sector_number in 0..count {
                for _ in 0..5 { inb(self.port + 7); /* Read the status register 5 times before using the result */ }
                while inb(self.port + 7) & (1 << 7) == 0 {} //Poll until status register is ready
                for i in 0..256 {
                    dst[(sector_number as usize * 256) + i] = inw(self.port);
                }
            }
        }
    }

}
