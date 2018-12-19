use core::intrinsics::transmute;

extern "C" {
	fn install_pagedirectory(pd4: u64);
}

pub type PhysicalAddress = u64;

pub const PAGE_SIZE: usize = 4096;
pub const TABLE_SIZE: usize = 512;

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

#[repr(C)]
pub struct PageDirectory {
	pub entries: [Entry; TABLE_SIZE]
}

pub fn setup(start_address: *mut u8) {

	println!("Setting up PT");

	unsafe {

		let root_pd = start_address as *mut PageDirectory;
		let root_pd3 = root_pd.offset(1);	
		let root_pd2 = root_pd3.offset(1);

		let root_pt1 = root_pd2.offset(1);
		let root_pt2 = root_pd2.offset(2);

		for i in 0..TABLE_SIZE {
			(*root_pd).entries[i].clear();
			(*root_pd3).entries[i].clear();
			(*root_pd2).entries[i].clear();
			//No point NULL PD1 as every entry is set
		}

		println!("PD4");

		(*root_pd).entries[0].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd3)),
			Flags::PRESENT | Flags::WRITABLE
		);

		(*root_pd).entries[511].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd)),
			Flags::PRESENT | Flags::WRITABLE
		);

		println!("PD3");

		(*root_pd3).entries[0].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd2)),
			Flags::PRESENT | Flags::WRITABLE
		);

		println!("PD2");

		(*root_pd2).entries[0].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pt1)),
			Flags::PRESENT | Flags::WRITABLE
		);

		(*root_pd2).entries[1].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pt2)),
			Flags::PRESENT | Flags::WRITABLE
		);

		println!("PT1");

		for i in 0..TABLE_SIZE {
			(*root_pt1).entries[i].set(
				Frame((i * PAGE_SIZE) as u64),
				Flags::PRESENT | Flags::WRITABLE
			);
		}

		println!("PT2");

		for i in 0..512 {	
			(*root_pt2).entries[i].set(
				Frame(((i * PAGE_SIZE) + (TABLE_SIZE * PAGE_SIZE)) as u64),
				Flags::PRESENT | Flags::WRITABLE
			);
		}

		println!("Install");
		install_pagedirectory(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd));
	}

	println!("Finished!");
}
