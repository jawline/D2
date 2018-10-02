pub mod serial;
pub mod stream;

#[macro_use]
pub mod print;

extern "C" {
    pub fn outb(port: u32, i: u8);
    pub fn inb(port: u32) -> u8;
}
