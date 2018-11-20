#![feature(lang_items)]
#![no_std]

#[macro_use]
mod io;
mod util;
mod memory;

use core::str;
use io::disk::ata_pio::{ROOT_PORT, ATAPIO};

use core::panic::PanicInfo;

#[no_mangle] pub extern fn rust_entry() { 

    println!("D2 Kernel - Booting Up"); 
    println!("RustLand Enabled");

    memory::start(0x0 as *const u8);

    let disk = ATAPIO::new(ROOT_PORT, true);
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
