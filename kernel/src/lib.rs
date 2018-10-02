#![feature(lang_items)]
#![no_std]

use core::panic::PanicInfo;

#[no_mangle]
pub extern fn rust_main() {
}

#[panic_handler] #[no_mangle] pub extern fn panic_fn(_i: &PanicInfo) -> ! { loop {} }
#[lang = "eh_personality"] #[no_mangle] pub extern fn eh_personality() {}
