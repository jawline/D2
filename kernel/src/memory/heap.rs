use core::mem;
use memory::mmap;

struct HeapEntry {
  used: bool,
  size: usize,
  prev: *mut HeapEntry
}

impl HeapEntry {
  fn next(&mut self) -> *mut HeapEntry {
    offset_bytes!(HeapEntry, self as *mut HeapEntry, self.size + mem::size_of::<HeapEntry>())
  }
}

pub struct Heap {
  root: *mut HeapEntry,
  limit: usize 
}

impl Heap {

  pub const fn empty() -> Heap {
    Heap {
      root: 0 as *mut HeapEntry,
      limit: 0
    }
  }

  pub fn new(start: *mut u8) -> Heap {
    const DEFAULT_SIZE: usize = 0x4000;

    mmap(start, DEFAULT_SIZE);

    let root_entry = start as *mut HeapEntry;

    unsafe {
      (*root_entry).used = false;
      (*root_entry).size = DEFAULT_SIZE - mem::size_of::<HeapEntry>();
      (*root_entry).prev = 0 as *mut HeapEntry;

      Heap {
        root: root_entry,
        limit: DEFAULT_SIZE
      }
    }
  }

  fn inside(&self, entry: *mut HeapEntry) -> bool {
    entry >= self.root && entry < offset_bytes!(HeapEntry, self.root, self.limit)
  }

  unsafe fn increase(&mut self, last: *mut HeapEntry, end: *mut HeapEntry) {
    const INCREASE_SIZE: usize = 0x1000;
    mmap(end as *mut u8, INCREASE_SIZE);
    (*end).used = false;
    (*end).size = INCREASE_SIZE - mem::size_of::<HeapEntry>();
    (*end).prev = last;
    self.limit += INCREASE_SIZE;
    debug!("HEAP INCREASE SIZE");
  }

  unsafe fn split_current(entry: *mut HeapEntry, size: usize) {
    const SPLIT_MARGIN: usize = 2; //The number of bytes left after a split before we bother saving them for later
    if (*entry).size - size > mem::size_of::<HeapEntry>() + SPLIT_MARGIN {
      let new_portion_size = (*entry).size - size;
      (*entry).size = size;
      let after = (*entry).next(); 
      (*after).used = false;
      (*after).size = new_portion_size;
      (*after).prev = entry;
    }
  }

  pub unsafe fn alloc(&mut self, size: usize) -> *mut u8 {

    /** Find next free block **/
    let mut current = self.root;

    loop {

      if !(*current).used && (*current).size > size {
        break;
      }

      let last = current;
      current = (*current).next();

      if !self.inside(current) {
        self.increase(last, current);
      }
    }

    //Split if it is large enough to become 2 heap entries
    //Then mark it as used
    Heap::split_current(current, size);
    (*current).used = true;

    offset_bytes!(u8, current, mem::size_of::<HeapEntry>())
  }

  unsafe fn merge_entry(&self, entry: *mut HeapEntry) {

    if !(*entry).prev.is_null() && !(*(*entry).prev).used {
      debug!("Heap Merge - Jump Left");
      return self.merge_entry((*entry).prev);
    }

    loop {
      let next = (*entry).next(); 
      if !self.inside(next) || (*next).used {
        break;
      }
      (*entry).size += (*next).size + mem::size_of::<HeapEntry>();
      debug!("Merged Entry");
    }

    debug!("Heap Merged");
  }

  pub unsafe fn free(&self, entry: *mut u8) {
    let entry = offset_bytes!(HeapEntry, entry, -(mem::size_of::<HeapEntry>() as isize));
    (*entry).used = false;
    self.merge_entry(entry);
  }
}
