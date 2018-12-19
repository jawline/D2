mod paging;

use io::print;
use util;
use core::str;

pub fn start(smap: *const u64) {
  println!("Starting memory manager");
	paging::setup(0x10000 as *mut u8);
	println!("Finished");
}

pub fn mmap(address: *const u8, length: usize, rules: u32) {
}
