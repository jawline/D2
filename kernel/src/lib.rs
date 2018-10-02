#![feature(lang_items)]
#![no_std]

#[macro_use]
mod io;

use io::print::*;

use core::panic::PanicInfo;

#[no_mangle] pub extern fn rust_entry() { 

    println!("D2 Kernel - Booting Up"); 
    println!("RustLand Enabled");

    loop {}
}

#[panic_handler] #[no_mangle] pub extern fn panic_fn(_i: &PanicInfo) -> ! { loop {} }
#[lang = "eh_personality"] #[no_mangle] pub extern fn eh_personality() {}
