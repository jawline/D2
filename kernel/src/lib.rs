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
use filesystems::fat16::fat16;

use core::alloc::Layout;
use core::panic::PanicInfo;

use memory::allocator::KernelAllocator;

#[global_allocator]
static mut KERNEL_HEAP: KernelAllocator = KernelAllocator::empty(); 

#[no_mangle] pub extern fn rust_entry(memory: *const u8) { 
  interrupts::disable();
	println!("[+] D2"); 
	
  unsafe { 
	  interrupts::start();
    memory::start(memory, &mut KERNEL_HEAP);
  }

  println!("[+] Scanning Disk");
	let mut disk = ATAPIO::new(ROOT_PORT, true);
  let mut fs = fat16::new(&mut disk);
  println!("[+] Disk Acquired");

	loop {}
}

#[alloc_error_handler] #[no_mangle] pub extern fn panic_oom(_i: Layout) -> ! { println!("OUT OF MEMORY"); loop {} }
#[panic_handler] #[no_mangle] pub extern fn panic_fn(_i: &PanicInfo) -> ! { println!("PANIC!"); loop {} }
