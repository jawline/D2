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

pub fn initialise(start: *const u8, pd: *mut PageDirectory) -> PageHolder {

	//TODO: Instead of putting it here map this space to a larger address
	//Then expand it using collected pages when necessary	
	let mut holder = Stack::new(0x7E00 as *mut u64);
	holder.limit = ((0x100000 - 0x7E00) / size_of::<u64>()) as isize;

	let mut seen = 0;

	unsafe {
		let mut iterator = start as *const SmapEntry;

		while (*iterator).length != 0 {
			if (*iterator).entry_type == 1 {
				let mut address = (*iterator).address;
				let max_address = (*iterator).address + (*iterator).length;

				while max_address - address > PAGE_SIZE as u64 {
					holder.push(address);
					address += PAGE_SIZE as u64;
				}
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
