use core::mem::{size_of, transmute};
use io::outb;

unsafe fn install_idt(idt: *const IDTTable) {
	asm!("lidtq (%rax)" :: "{rax}"(idt));
}

#[repr(packed)]
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
	pub unsafe fn set(&mut self, handler: fn() -> (), selector: u16, flags: u8) {
    let hdl = transmute::<fn() -> (), usize>(handler);
    self.ist = 0;
    self.selector = selector;
    self.type_attr = flags | 0x60;
    self.reserved = 0;

    self.offset_1 = (hdl & 0xFFFF) as u16;
    self.offset_2 = ((hdl >> 16) & 0xFFFF) as u16;
    self.offset_3 = (hdl >> 32) as u32;
	}
}

#[repr(packed)]
struct IDTTable {
	size: u16,
	offset: u64,
	entries: [IDTDescriptor; 256]
}

impl IDTTable {
	pub unsafe fn setup(&mut self) {
		self.size = ((size_of::<IDTDescriptor>() * self.entries.len()) - 1) as u16;
	  self.offset = transmute::<&IDTDescriptor, u64>(&self.entries[0]);
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

unsafe fn reset_pic() {
  outb(0xA0, 0x20);
  outb(0x20, 0x20);
}

fn page_fault_handler() {
  disable();
  unsafe { reset_pic(); }
	println!("Page Fault");
  loop {}
}

fn stub_handler() {
  disable();
  unsafe { reset_pic(); }
  debug!("General ISR stub hit");
  enable();
  unsafe { asm!("iretq"); }
}

pub unsafe fn start() {

  println!("[+] IDT: Start");
  
  println!("[+] IDT Table");
  IDT_TABLE.setup();

  println!("[+] IDT: Stubs");

	for item in IDT_TABLE.entries.iter_mut() {
	  item.set(stub_handler, 0x8, 0x8E);
	}

  IDT_TABLE.entries[0].set(page_fault_handler, 0x8, 0x8E);

	println!("[+] IDT: Install");
	install_idt(&IDT_TABLE as *const IDTTable);

	println!("[+] IDT: Done");
}

pub fn enable() {
  unsafe { asm!("sti"); }
}

pub fn disable() {
  unsafe { asm!("cli"); }
}
