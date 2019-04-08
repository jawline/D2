#![feature(lang_items)]
#![feature(asm)]
#![no_std]

#[macro_use]
extern crate bitflags;

#[macro_use]
mod io;

#[macro_use]
mod debug;

mod util;
mod memory;
mod interrupts;
mod filesystems;

use core::str;
use io::disk::ata_pio::{ROOT_PORT, ATAPIO};
use io::disk::Disk;

use core::panic::PanicInfo;

#[no_mangle] pub extern fn rust_entry(memory: *const u8) { 

	println!("[+] D2"); 

	interrupts::start();
	memory::start(memory);

  let scratch_pad = memory::kmalloc(500);

  for i in 0..500 {
    unsafe {
      (*scratch_pad.offset(i)) = 0xFA;
    }
  }

  let scratch_pad_2 = memory::kmalloc(450);
  for i in 0..450 {
    unsafe { (*scratch_pad.offset(i)) = 0xAA; }
  }
 
  println!("[+] Pads Scratched"); 
  unsafe { asm!("" :: "{rax}"(scratch_pad), "{rbx}"(scratch_pad_2)); }

  memory::kfree(scratch_pad);
  memory::kfree(scratch_pad_2);

  loop {}

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

#[panic_handler] #[no_mangle] pub extern fn panic_fn(_i: &PanicInfo) -> ! { loop {} }
#[lang = "eh_personality"] #[no_mangle] pub extern fn eh_personality() {}
