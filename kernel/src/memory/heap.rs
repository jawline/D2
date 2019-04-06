use core::mem;
use memory::mmap;

struct HeapEntry {
  used: bool,
  size: usize,
  prev: *mut HeapEntry
}

pub struct Heap {
  root: *mut HeapEntry,
  limit: usize
}

impl Heap {
  pub fn new(start: *mut u8) -> Heap {
    const DEFAULT_SIZE: usize = 0x4000;

    mmap(start, DEFAULT_SIZE);

    let root_entry = start as *mut HeapEntry;

    unsafe {
      (*root_entry).used = false;
      (*root_entry).size = DEFAULT_SIZE;
      (*root_entry).prev = 0 as *mut HeapEntry;
    }

    Heap {
      root: root_entry,
      limit: DEFAULT_SIZE
    }
  }

  pub fn alloc(&self, size: usize) -> *mut u8 {
    const INCREASE_SIZE: usize = 0x4000;
    unsafe {
    /** Find next free block **/
    let mut current = self.root;

    loop {

      if !(*current).used && (*current).size > size {
        break;
      }

      current = (current as *mut u8).offset(((*current).size + mem::size_of::<HeapEntry>()) as isize) as *mut HeapEntry;

      if current as usize > self.limit {
        mmap((self.root as *mut u8).offset(self.limit as isize), INCREASE_SIZE);
      } 
    }

    //Take what we need
    (*current).used = true;

    (current as *mut u8).offset(mem::size_of::<HeapEntry>() as isize)
    }
  }

  pub fn free(entry: *mut u8) {
    unsafe {
      let entry = entry.offset(-(mem::size_of::<HeapEntry>() as isize)) as *mut HeapEntry;
      (*entry).used = false;
    }
  }
}
