pub mod serial;
pub mod disk;
pub mod stream;

#[macro_use]
pub mod print;

extern "C" {
    pub fn outb(port: u16, i: u8);
    pub fn inb(port: u16) -> u8;
    pub fn outw(port: u16, i: u16);
    pub fn inw(port: u16) -> u16;
}
