use core::intrinsics::transmute;
use memory::smap::PageHolder;

pub const PAGE_SIZE: usize = 4096;
pub const TABLE_SIZE: usize = 512;
pub type PhysicalAddress = u64;

unsafe fn install_pd4(pd4: *const PageDirectory) {
	asm!("mov %rdi, %cr3
        mov %cr0, %rax
	      mov %rax, %cr0" :: "{rdi}"(pd4));
}

unsafe fn invalidate_pd4() {
	asm!("mov %cr3, %rdi
	      mov %rdi, %cr3");
}

unsafe fn invalidate_page(addr: *const u8) {
	asm!("invlpg (%rdi)" :: "{rdi}"(addr))
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
		self.0 == 0
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
 			let entry = &mut self.entries[index];
      let memory_frame = holder.pop();
      entry.set(Frame(memory_frame), Flags::PRESENT | Flags::WRITABLE);
			unsafe {
			  invalidate_pd4();
			}
			debug!("Set frame");
		} else {
      debug!("Reused Frame");
    }
		self.next_address(index) as *mut PageDirectory
	}

	fn next_address(&self, index: usize) -> PhysicalAddress {
		let this_table_address = self as *const _ as PhysicalAddress;
		(this_table_address << 9) | ((index as PhysicalAddress) << 12)
	}

  fn clear(&mut self) {
    for i in 0..512 {
      self.entries[i].clear();
    }
  }
}

pub fn map(virtual_address: u64, physical_address: u64, p4: *mut PageDirectory, holder: &mut PageHolder) {
  unsafe {
    let p3 = (*p4).select(p4_entry(virtual_address), holder);
    let p2 = (*p3).select(p3_entry(virtual_address), holder);
    let p1 = (*p2).select(p2_entry(virtual_address), holder);
    (*p1).entries[p1_entry(virtual_address)].set(
      Frame(physical_address),
      Flags::PRESENT | Flags::WRITABLE
    );
    invalidate_pd4();
    debug!("Mapped Page");
	}
}

pub fn setup(start_address: *mut u8, smap: PhysicalAddress) -> *mut PageDirectory {
	unsafe {

    println!("[+] Memory: Reusing Existing Page Table");

		let root_pd = start_address as *mut PageDirectory;

		(*root_pd).entries[511].set(
			Frame(transmute::<*mut PageDirectory, PhysicalAddress>(root_pd)),
			Flags::PRESENT | Flags::WRITABLE
		);

    println!("[+] Memory: CR3");

		install_pd4(root_pd);

    println!("[+] Memory: Installed");
		0xFFFFFFFF_FFFFF000 as *mut PageDirectory
	}
}
