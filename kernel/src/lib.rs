#![feature(lang_items, asm, alloc_error_handler)]
#![no_std]
#![allow(dead_code)]

#[macro_use]
extern crate bitflags;
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

use alloc::vec::Vec;
use io::disk::ata_pio::{ROOT_PORT, ATAPIO};
use filesystems::fat16::Fat16;

use core::alloc::Layout;
use core::panic::PanicInfo;

use memory::allocator::KernelAllocator;

#[global_allocator]
static mut KERNEL_HEAP: KernelAllocator = KernelAllocator::default(); 

#[no_mangle] pub extern fn rust_entry(memory: *const u8) { 
  
  interrupts::disable();

	println!("[+] D2 - Core"); 

  unsafe { 
	  interrupts::start();
    memory::start(memory, &mut KERNEL_HEAP);
  }

  println!("[+] D2 - Core Done");

  interrupts::enable();

  println!("[+] Scanning Disk");
	let mut disk = ATAPIO::new(ROOT_PORT, true);
  let fs = Fat16::new(&mut disk);
  println!("[+] Disk Acquired");

	loop {}
}

#[alloc_error_handler] #[no_mangle] pub extern fn panic_oom(_i: Layout) -> ! { println!("OUT OF MEMORY"); loop {} }
#[panic_handler] #[no_mangle] pub extern fn panic_fn(_i: &PanicInfo) -> ! { println!("PANIC!"); loop {} }
