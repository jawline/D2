pub const SECTOR_SIZE: usize = 512;

//TODO: Disks should be restructured to throw errors
pub trait Disk {
  fn read(&self, sector: u64, count: u8, dst: &mut [u8]);
  fn write(&self, sector: u64, count: u8, src: &mut [u8]);
}

pub mod ata_pio;
