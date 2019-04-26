/**
 * Definitions of C utility functions
 * TODO: Replace this with optimized versions
 */

use core::cmp;
use core::mem::size_of;
use alloc::alloc::{alloc, dealloc, Layout};

/**
 * Implementation will copy as much data as possible using 64 bit writes before falling back to 8 bit writes
 */
#[no_mangle]
pub unsafe extern fn memset(addr: *mut u8, value: i32, size: usize) {
  debug!("memset");

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
  debug!("memcpy");
  
  if size == 0 {
    return;
  }
  
  let from_64 = from as *mut u64;
  let to_64 = to as *mut u64;

  //Do as much as possible in 64 bit chunks
  for i in 0..(size / size_of::<u64>()) {
    let i = i as isize;
    *to_64.offset(i) = *from_64.offset(i);
  }

  //Copy the remainder byte by byte
  let remaining = size % size_of::<u64>();
  for i in size - remaining..size {
    let i = i as isize;
    *to.offset(i) = *from.offset(i);
  }
}

/**
 * Find the overlap (if any) between two pointers
 */
unsafe fn find_overlap(from: *mut u8, to: *mut u8, size: usize) -> Option<(*mut u8, *mut u8)> {
  let from_end = from.offset(size as isize);
  let to_end = to.offset(size as isize);

  let intersect_start = cmp::max(from, to);
  let intersect_end = cmp::min(from_end, to_end);

  if intersect_end > intersect_start {
    None
  } else {
    Some((intersect_start, intersect_end))
  }
}


/**
 * This implementation uses the minimum amount of scratch space to handle a memmove (memcpy of potentially overlapping regions).
 */
#[no_mangle]
pub unsafe extern fn memmove(from: *mut u8, to: *mut u8, size: usize) {
  debug!("mmove");

  let intersection = find_overlap(from, to, size);

  if let Some((start, end)) = intersection { 

    //First allocate the space for the shared region and save it for later
    let volatile_region_size = (end as usize) - (start as usize);
    let layout = Layout::from_size_align(volatile_region_size, 1).unwrap();
    let scratch_pad: *mut u8 = alloc(layout);
    memcpy(start, scratch_pad, volatile_region_size);

    //We want to do the minimum amount of memcpy
    //If to < from then the volatile region will be at the start of from
    //If from < to then the volatile region will be at the end of from
    if from < to {
      memcpy(from, to, size - volatile_region_size);
    } else {
      memcpy(
        from.offset(volatile_region_size as isize),
        to.offset(volatile_region_size as isize),
        size - volatile_region_size
      );
    }

    //Next find the offset between from and the shared space
    let offset_to_volatile = (start as usize) - (from as usize);
    
    //Finally, copy the stored volatile region into to, offset by the distance from from
    memcpy(scratch_pad, to.offset(offset_to_volatile as isize), volatile_region_size);

    dealloc(scratch_pad, layout);
  } else {
    memcpy(from, to, size);
  }
}

#[no_mangle]
pub unsafe extern fn memcmp(from: *mut u8, to: *mut u8, size: usize) -> i32 {
  debug!("memcmp");
  for i in 0..size {
    let i = i as isize;
    let delta_byte = (*from.offset(i) as i32) - (*to.offset(i) as i32);
    if delta_byte != 0 {
      return delta_byte;
    }
  }
  0
}
