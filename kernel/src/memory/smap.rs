use io::print;
use util;
use core::str;
use core::mem::{transmute, size_of};

use memory::stack::Stack;
use memory::paging::{map, PageDirectory, PAGE_SIZE, PhysicalAddress};

#[repr(C)]
struct SmapEntry {
  address: u64,
	length: u64,
	entry_type: u32,
	acpi_bf: u32
}

pub type PageHolder = Stack<PhysicalAddress>;

impl PageHolder {
	pub fn push_frame(&mut self, address: PhysicalAddress, pd: *mut PageDirectory) {
		//If the next 
		if self.limit == 0 || self.current == self.limit {
			unsafe {
				println!("Using to store frames");
				map(transmute::<*mut PhysicalAddress, PhysicalAddress>(self.entries.offset(self.limit)), address, pd);
				self.limit += (PAGE_SIZE / size_of::<PhysicalAddress>()) as isize;
			}
		} else {
			println!("Storing in remaining space");
			self.push(address);
		}
	}
}

pub fn initialise(start: *const u8, pd: *mut PageDirectory) -> PageHolder {

	let mut holder = Stack::new(0x900000 as *mut u64);

	let mut seen = 0;

	unsafe {
		let mut iterator = start as *const SmapEntry;

		while (*iterator).length != 0 {

			if (*iterator).entry_type == 1 {

				let mut address = (*iterator).address;
				let max_address = (*iterator).address + (*iterator).length;

				while max_address - address > PAGE_SIZE as u64 {
					holder.push_frame(address, pd);
					address += PAGE_SIZE as u64;
				}
				println!("Usable!");
			
			}

			seen += 1;
			iterator = iterator.add(1);
		}

		println!("SMAP Scanned");
	}

	let mut byte_buffer = [0 as u8; 512];
	util::itoa_bytes(seen, 16, &mut byte_buffer);
	println!(str::from_utf8(&mut byte_buffer).unwrap());

	holder
}
