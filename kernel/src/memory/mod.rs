mod paging;
mod smap;
mod stack;

use io::print;
use util;
use core::str;

pub fn start(smap: *const u8) {
  println!("Starting memory manager");
	let mut page_table = paging::setup(0x1000 as *mut u8);
	smap::initialise(smap, page_table);
	println!("Finished");
}

pub fn mmap(address: *const u8, length: usize, rules: u32) {
}
