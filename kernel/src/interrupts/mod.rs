use core::mem::transmute;
use memory::PhysicalAddress;

unsafe fn install_idt(idt: *const IDTTable) {
	asm!("lidt (%rdi)" :: "{rdi}"(idt));
}

#[repr(C)]
#[derive(Copy, Clone)]
struct IDTDescriptor {
	offset_1: u16,
	selector: u16,
	ist: u8,
	type_attr: u8,
	offset_2: u16,
	offset_3: u32,
	reserved: u32
}

impl IDTDescriptor {
	pub fn set(&mut self, handler: fn() -> (), selector: u16, flags: u8) {
		unsafe {
			let hdl = transmute::<fn() -> (), PhysicalAddress>(handler);
			self.ist = 0;
			self.selector = selector;
			self.type_attr = flags | 0x60;
			self.reserved = 0;

			self.offset_1 = (hdl & 0xFFFF) as u16;
			self.offset_2 = ((hdl >> 16) & 0xFFFF) as u16;
			self.offset_3 = (hdl >> 32) as u32;
		}
	}
}

#[repr(C)]
struct IDTTable {
	size: u16,
	offset: u64,
	entries: [IDTDescriptor; 256]
}

impl IDTTable {
	pub fn setup(&mut self) {
		self.size = 256;
		unsafe {
			self.offset = transmute::<&IDTDescriptor, u64>(&self.entries[0]);
		}
	}
}

static mut IDT_TABLE: IDTTable = IDTTable {
	size: 0,
	offset: 0,
	entries: [IDTDescriptor {
		offset_1: 0,
		selector: 0,
		ist: 0,
		type_attr: 0,
		offset_2: 0,
		offset_3: 0,
		reserved: 0
	}; 256]
};

fn stub_handler() {

	unsafe {
		asm!("cli");
	}

	println!("Stub Hit!!!");
} 

pub fn start() {

	unsafe {
		IDT_TABLE.setup();
	}

	unsafe {
	for item in IDT_TABLE.entries.iter_mut() {
			item.set(stub_handler, 0x8, 0x8E);
	}
	}

	println!("Setting IDT");

	unsafe {
		install_idt(&IDT_TABLE as *const IDTTable);
	}

	println!("Finished setting up IDT");

	loop {
		unsafe {
			asm!("sti
			      mov 5, %rax
			      mov 10, %rdx
			      div %rdx");
		}
	}

}
