#![feature(lang_items)]
#![no_std]

#[macro_use]
mod io;

use io::disk::ata_pio::{ROOT_PORT, ATAPIO};

use core::panic::PanicInfo;

#[no_mangle] pub extern fn rust_entry() { 

    println!("D2 Kernel - Booting Up"); 
    println!("RustLand Enabled");

    println!("Hello.");

    let disk = ATAPIO::new(ROOT_PORT, true);
    let mut data = [0 as u8; 512];
    disk.read(0, 1, &mut data); 

    loop {}
}

#[panic_handler] #[no_mangle] pub extern fn panic_fn(_i: &PanicInfo) -> ! { loop {} }
#[lang = "eh_personality"] #[no_mangle] pub extern fn eh_personality() {}
