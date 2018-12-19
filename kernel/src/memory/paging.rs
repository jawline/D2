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

pub struct Frame(u64);

impl Frame {
	pub fn resolve(&self) -> u64 {
		(self.0 << 12) & 0x000fffff_fffff000
	}
}

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

pub struct PageTable {
	entries: [u64]
}

pub fn setup() {
}
