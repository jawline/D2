/**
 * Definitions of C utility functions
 * TODO: Replace this with optimized versions
 */


/**
 * Implementation will copy as much data as possible using 64 bit writes before falling back to 8 bit writes
 */
#[no_mangle]
pub unsafe extern fn memset(addr: *mut u8, value: i32, size: usize) {

  //First truncate value to a char, then generate value_u64 which is value repeated 8 times
  let value_u8 = value as u8;
  let value_u32 = value_u8 as u32;
  let value_u32: u32 = value_u32 & (value_u32 << 8) & (value_u32 << 16) & (value_u32 << 24);
  let value_u64: u64 = (value_u32 as u64) & ((value_u32 as u64) << 32);


  //Use 64 bit writes to do as much of the memset as possible
  let addr_64 = addr as *mut u64;
  for i in 0..(size / 8) {
    *addr_64.offset(i as isize) = value_u64; 
  }

  //Calculate how much we have left
  let remaining = size % 8;

  for i in size - remaining..size {
    *addr.offset(i as isize) = value_u8;
  }
}

/**
 * Copies as much as possible in 64 bit chunks and then the remainder (up to 7 bytes) byte by byte
 */
#[no_mangle]
pub unsafe extern fn memcpy(from: *mut u8, to: *mut u8, size: usize) {
  let from_64 = from as *mut u64;
  let to_64 = to as *mut u64;

  //Do as much as possible in 64 bit chunks
  for i in 0..(size / 8) {
    let i = i as isize;
    *to_64.offset(i) = *from_64.offset(i);
  }

  //Copy the remainder byte by byte
  let remaining = size % 8;
  for i in size - remaining..size {
    let i = i as isize;
    *to.offset(i) = *from.offset(i);
  }
}

#[no_mangle]
pub unsafe extern fn memmove(from: *mut u8, to: *mut u8, size: usize) {
}

#[no_mangle]
pub unsafe extern fn memcmp(from: *mut u8, to: *mut u8, size: usize) -> i32 {
  0
}
