#[macro_use]
pub mod print;

pub mod serial;
pub mod disk;
pub mod stream;

pub unsafe fn outb(port: u16, value: u8) {
	asm!("outb %al, %dx" :: "{dx}"(port), "{al}"(value));
}

pub unsafe fn outw(port: u16, value: u16) {
	asm!("outw %ax, %dx" :: "{dx}"(port), "{ax}"(value));
}

pub unsafe fn inb(port: u16) -> u8 {
	let result;
	asm!("inb %dx, %al" : "={al}"(result) : "{dx}"(port));
	result
}

pub unsafe fn inw(port: u16) -> u16 {
	let result;
	asm!("inw %dx, %ax" : "={ax}"(result) : "{dx}"(port));
	result
}
