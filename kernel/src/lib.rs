#![feature(lang_items)]
#![no_std]

mod io;

use io::serial::Serial;

use core::panic::PanicInfo;

#[no_mangle]
pub extern fn rust_main() {
    unsafe {
        let a = 0x7C00 as *mut u8;
        *a = 10;
    }

    let serial = Serial::new();

    loop {
        serial.putc('H' as u8);
        unsafe {
            let a = 0x7C00 as *mut u8;
            *a = 15;
        }
    }
}

#[panic_handler] #[no_mangle] pub extern fn panic_fn(_i: &PanicInfo) -> ! { loop {} }
#[lang = "eh_personality"] #[no_mangle] pub extern fn eh_personality() {}
