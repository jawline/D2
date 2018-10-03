use io::{outb, inb, inw};

const MASTER: u8 = 0xE0;
const ROOT_PORT: u16 = 0x1F0;

pub struct ATAPIO {
    master: bool
}

/**
 * 28 bit ATA PIO Polling implementation
 * For the most basic file system access
 */

impl ATAPIO {

    pub fn read(&self, sector: u32, count: u8, dst: &mut [u8]) {
        let sector = sector & 0x00FFFFFF;
        let slave_bit = if (self.master) { 1 } else { 0 };
        let mut dst_idx = 0;

        unsafe {
            outb(ROOT_PORT + 6, (MASTER | (slave_bit << 4)) | (sector >> 24 & 0x0F) as u8); //Send slave or master with the upper 4 bits to the final port
            outb(ROOT_PORT + 1, 0); //Null to root port
            outb(ROOT_PORT + 2, count); //Send the sector count
            outb(ROOT_PORT + 3, (sector & 0xFF) as u8); //Lower 8 bits
            outb(ROOT_PORT + 4, ((sector >> 8) & 0xFF) as u8); //Middle 8 bits
            outb(ROOT_PORT + 5, ((sector >> 16) & 0xFF) as u8); //16-24 bits
            outb(ROOT_PORT + 7, 0x20); //READ SECTORS command

            while inb(ROOT_PORT + 7) & (1 << 7) == 0 {} //Poll until status register is ready

            for sector_number in 0..count {
                for i in 0..256 {
                    let next_byte = inw(ROOT_PORT);
                    dst[(sector_number as usize * 256) + i] = ((next_byte >> 8) & 0xFF) as u8;
                    dst[(sector_number as usize * 256) + i + 1] = (next_byte & 0xFF) as u8; 
                }
            }
        }
    }

}
