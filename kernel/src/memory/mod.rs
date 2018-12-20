mod paging;
mod smap;
mod stack;

use io::print;
use util;
use core::str;

use memory::paging::{ PageDirectory, PhysicalAddress, map, PAGE_SIZE };
use memory::smap::PageHolder;

static mut PD4: *mut PageDirectory = 0x0 as *mut PageDirectory;
static mut SPARE_PAGES: PageHolder = PageHolder {
	entries: 0x0 as *mut PhysicalAddress,
	current: 0,
	limit: 0
};

pub fn start(smap: *const u8) {
  println!("Starting memory manager");

	unsafe {
		PD4 = paging::setup(0x1000 as *mut u8, 0x1000000);
		SPARE_PAGES = smap::initialise(smap, PD4);
	}

	println!("Finished");

	mmap(0x5000000 as *const u8, PAGE_SIZE * 4);
}

pub fn mmap(address: *const u8, length: usize) {
	println!("PMAP");
	let address = address as PhysicalAddress;
	let max = address + (length as PhysicalAddress);
	unsafe {
		for i in (address..max).step_by(PAGE_SIZE) {
			let new_page = SPARE_PAGES.pop();
			println!("Starting the map");
			paging::map(i, new_page, PD4, &mut SPARE_PAGES);
		}
	}

	println!("DMAP");
	loop {}
}
