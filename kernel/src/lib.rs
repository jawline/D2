#![feature(lang_items, asm, alloc_error_handler)]
#![no_std]

#[macro_use]
extern crate bitflags;
#[macro_use]
extern crate alloc;

#[macro_use]
mod io;

#[macro_use]
mod debug;
#[macro_use]
mod util;

mod memory;
mod interrupts;
mod filesystems;

use core::str;
use alloc::vec::Vec;
use io::disk::ata_pio::{ROOT_PORT, ATAPIO};
use io::disk::Disk;

use core::alloc::Layout;
use core::panic::PanicInfo;

use memory::allocator::KernelAllocator;

#[global_allocator]
static mut KERNEL_HEAP: KernelAllocator = KernelAllocator::empty(); 

#[no_mangle] pub extern fn rust_entry(memory: *const u8) { 

	println!("[+] D2"); 

	interrupts::start();
	
  unsafe {
    memory::start(memory, &mut KERNEL_HEAP);
  }

  let mut v = Vec::new();
  v.push(5);
  v.push(6);
  v.push(10);

  println!("[+] Scanning Disk");
	let disk = ATAPIO::new(ROOT_PORT, true);
  println!("[+] Disk Acquired");

	let mut data = [0 as u8; 512];
	disk.read(0, 1, &mut data); 

	println!("Done a disk read.");

	let mut byte_buffer = [0 as u8; 512];
	util::itoa_bytes(data[0] as i32, 16, &mut byte_buffer);
  println!(str::from_utf8(&mut byte_buffer).unwrap());

	println!("Done a convert.");

	loop {}
}

#[alloc_error_handler] #[no_mangle] pub extern fn panic_oom(_i: Layout) -> ! { loop {} }
#[panic_handler] #[no_mangle] pub extern fn panic_fn(_i: &PanicInfo) -> ! { loop {} }
#[lang = "eh_personality"] #[no_mangle] pub extern fn eh_personality() {}
#[lang = "eh_unwind_resume"] extern fn rust_eh_unwind_resume() {}
#[no_mangle] pub extern fn rust_eh_register_frames () {}
#[no_mangle] pub extern fn rust_eh_unregister_frames () {}
