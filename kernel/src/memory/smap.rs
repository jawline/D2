use core::mem::{size_of};

use memory::stack::Stack;
use memory::paging::{PageDirectory, PAGE_SIZE, PhysicalAddress};

#[repr(C)]
struct SmapEntry {
  address: u64,
	length: u64,
	entry_type: u32,
	acpi_bf: u32
}

pub type PageHolder = Stack<PhysicalAddress>;

/**
 * TODO: The SMAP Should mmap pages as it goes to hold memory for free pages
 */
pub fn initialise(start: *const u8, _pd: *mut PageDirectory) -> PageHolder {

  println!("[+] SMAP: Start");

	//TODO: Instead of putting it here map this space to a larger address
	//Then expand it using collected pages when necessary	
	let mut holder = Stack::new(0x7E00 as *mut u64);
	holder.limit = ((0x100000 - 0x7E00) / size_of::<u64>()) as isize;

	unsafe {
		let mut iterator = start as *const SmapEntry;

		while (*iterator).length != 0 {
			if (*iterator).entry_type == 1 {
				let mut address = (*iterator).address;
				let max_address = (*iterator).address + (*iterator).length;

				while max_address - address > PAGE_SIZE as u64 {
					if address < 0x100000 {
            holder.push(address);
					  address += PAGE_SIZE as u64;
          } else {
            break;
          }
				}
			}

			iterator = iterator.add(1);
		}
	}

  println!("[+] SMAP: End");
	holder
}
