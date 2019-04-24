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
  fat: [u8] 
}
