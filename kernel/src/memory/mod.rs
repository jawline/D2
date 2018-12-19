mod paging;

use io::print;
use util;
use core::str;

pub const PAGE_SIZE: usize = 4096;

pub fn start(smap: *const u64) {
  println!("Starting memory manager");
	println!("Finished");
}

pub fn mmap(address: *const u8, length: usize, rules: u32) {
}
