use alloc::vec::Vec;
use core::str;
use io::disk::{Disk, SECTOR_SIZE};
use core::mem::{size_of, transmute};
use util::c_utilities::memcpy;

const FAT_BPP_OFFSET: isize = 3;

#[repr(packed)]
#[derive(Default)]
pub struct fat16_bpp {
  oem_identifier: [u8; 8],
  bytes_per_sectorn: u16,
  sectors_per_cluster: u8,
  reserved_sectors: u16,
  num_fats: u8,
  max_root_entries: u16,
  sector_count: u16,
  junk_1: u8,
  sectors_per_fat: u16,
  sectors_per_track: u16,
  num_heads: u16,
  hidden_sectors: u32,
  large_sector_count: u32,
  drive_number: u8,
  window_nt_flags: u8,
  boot_signature: u8,
  volume_id: u32,
  label: [u8; 11],
  fs_type: [u8; 8]
}

pub struct fat16 {
  bpp: fat16_bpp, 
  fat: Vec<u8>
}

impl fat16 { 

  pub fn new(disk: &mut Disk) -> Option<fat16> {

    let mut new_fs = fat16 {
      bpp: fat16_bpp::default(), 
      fat: Vec::new()
    };

    debug!("Starting to load a FAT16 disk");

    let mut root_sector = [0; SECTOR_SIZE];
    disk.read(0, 1, &mut root_sector);

    debug!("Read root sector");

    debug!("Transcribing the bpp");

    unsafe {
      memcpy(root_sector.as_mut_ptr().offset(FAT_BPP_OFFSET),
        transmute::<&mut fat16_bpp, *mut u8>(&mut new_fs.bpp),
        size_of::<fat16_bpp>());
    }

    new_fs.bpp.oem_identifier[7] = 0;

    debug!("Ok, printing");

    if let Ok(oem) = str::from_utf8(&new_fs.bpp.oem_identifier) {
      println!(oem);
    }

    //unsafe { asm!("" :: "rax"(&root_sector as *const u8)); }
    loop {}

    Some(new_fs)
  }

} 
