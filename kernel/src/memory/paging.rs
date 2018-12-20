use core::intrinsics::transmute;
use memory::smap::PageHolder;

pub const PAGE_SIZE: usize = 4096;
pub const TABLE_SIZE: usize = 512;
pub type PhysicalAddress = u64;

extern "C" {
	fn install_pagedirectory(pd4: u64);
}

bitflags! {
    pub struct Flags: u64 {
        const PRESENT =         1 << 0;
        const WRITABLE =        1 << 1;
        const USER_ACCESSIBLE = 1 << 2;
        const WRITE_THROUGH =   1 << 3;
        const NO_CACHE =        1 << 4;
        const ACCESSED =        1 << 5;
        const DIRTY =           1 << 6;
        const HUGE_PAGE =       1 << 7;
        const GLOBAL =          1 << 8;
        const NO_EXECUTE =      1 << 63;
    }
}

pub struct Frame(PhysicalAddress);

impl Frame {
	pub fn resolve(&self) -> u64 {
		self.0 & 0x000fffff_fffff000
	}
}

#[derive(Copy, Clone)]
#[repr(C)]
pub struct Entry(u64);

impl Entry {

	pub fn set(&mut self, address: Frame, flags: Flags) {
		self.0 = address.resolve() | flags.bits();
	}

	pub fn flags(&self) -> Flags {
		Flags::from_bits_truncate(self.0)
	}

	pub fn is_clear(&self) -> bool {
		self.0 != 0
	}

	pub fn clear(&mut self) {
		self.0 = 0;
	}

}

fn p4_entry(addr: PhysicalAddress) -> usize {
    ((addr >> 27) & 0o777) as usize
}
fn p3_entry(addr: PhysicalAddress) -> usize {
    ((addr >> 18) & 0o777) as usize
}
fn p2_entry(addr: PhysicalAddress) -> usize {
    ((addr >> 9) & 0o777) as usize
}
fn p1_entry(addr: PhysicalAddress) -> usize {
    ((addr >> 0) & 0o777) as usize
}

#[repr(C)]
pub struct PageDirectory {
	pub entries: [Entry; TABLE_SIZE]
}

impl PageDirectory {

	pub fn select(&mut self, index: usize, holder: &mut PageHolder) -> *mut PageDirectory {

		if self.entries[index].is_clear() {
			self.entries[index].set(
				Frame(holder.pop()),
				Flags::PRESENT | Flags::WRITABLE
			);	
		}

		self.next_address(index) as *mut PageDirectory
	}

	fn next_address(&self, index: usize) -> PhysicalAddress {
		let this_table_address = self as *const _ as PhysicalAddress;
		(this_table_address << 9) | ((index as PhysicalAddress) << 12)
	}

}

pub fn map(virtual_address: u64, physical_address: u64, pd: *mut PageDirectory, holder: &mut PageHolder) {	
    unsafe {
			let mut p3 = (*pd).select(p4_entry(virtual_address), holder);
			let mut p2 = (*p3).select(p3_entry(virtual_address), holder); 
			let mut p1 = (*p2).select(p2_entry(virtual_address), holder);
			(*p1).entries[p1_entry(virtual_address)].set(
				Frame(physical_address),
				Flags::PRESENT | Flags::WRITABLE
			);
		}
}

pub fn setup(start_address: *mut u8, smap: PhysicalAddress) -> *mut PageDirectory {

	unsafe {

		let root_pd = start_address as *mut PageDirectory;
		let root_pd3 = root_pd.offset(1);	
		let root_pd2 = root_pd3.offset(1);

		let root_pt1 = root_pd2.offset(1);
		let root_pt2 = root_pd2.offset(2);

		(*root_pd).entries[0].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd3)),
			Flags::PRESENT | Flags::WRITABLE
		);

		(*root_pd).entries[511].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd)),
			Flags::PRESENT | Flags::WRITABLE
		);

		(*root_pd3).entries[0].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd2)),
			Flags::PRESENT | Flags::WRITABLE
		);

		(*root_pd2).entries[0].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pt1)),
			Flags::PRESENT | Flags::WRITABLE
		);

		(*root_pd2).entries[1].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pt2)),
			Flags::PRESENT | Flags::WRITABLE
		);

		for i in 0..TABLE_SIZE {
			(*root_pt1).entries[i].set(
				Frame((i * PAGE_SIZE) as u64),
				Flags::PRESENT | Flags::WRITABLE
			);
			
			(*root_pt2).entries[i].set(
				Frame(((i * PAGE_SIZE) + (TABLE_SIZE * PAGE_SIZE)) as u64),
				Flags::PRESENT | Flags::WRITABLE
			);
		}

		install_pagedirectory(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd));
		root_pd
	}
}
