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

#[repr(C)]
struct IDTTable {
	size: u8,
	offset: *const u8,
	entries: [IDTDescriptor; 256]
}

static mut IDT_TABLE: IDTTable = IDTTable {
	size: 256,
	offset: 0 as *const u8,
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

pub fn start() {
	println!("Setting up IDT");

	println!("Created IDT");

	println!("Setting IDT");

}
