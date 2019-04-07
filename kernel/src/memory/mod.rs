mod paging;
mod smap;
mod stack;
mod heap;
mod kheap;

use util;

pub use memory::paging::PhysicalAddress;
use memory::paging::{ PageDirectory, map, PAGE_SIZE };
use memory::smap::PageHolder;

static mut PD4: *mut PageDirectory = 0x0 as *mut PageDirectory;
static mut SPARE_PAGES: PageHolder = PageHolder {
	entries: 0x0 as *mut PhysicalAddress,
	current: 0,
	limit: 0
};

pub fn start(smap: *const u8) {
  println!("[+] Memory: Start");

	unsafe {
		PD4 = paging::setup(0x1000 as *mut u8, 0x1000000);
	  SPARE_PAGES = smap::initialise(smap, PD4);
	}

  println!("[+] Initializing Kernel Heap");
  kheap::init();

	println!("[+] Memory: Finish");
}

pub fn mmap(address: *const u8, length: usize) {
	debug!("PMAP");
	let address = address as PhysicalAddress;
	let max = address + (length as PhysicalAddress);
	unsafe {
		for i in (address..max).step_by(PAGE_SIZE) {
			let new_page = SPARE_PAGES.pop();
			paging::map(i, new_page, PD4, &mut SPARE_PAGES);
		}
	}
}

pub use self::heap::Heap;
