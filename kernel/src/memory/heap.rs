use core::mem;
use memory::mmap;

struct HeapEntry {
  used: bool,
  size: usize,
  prev: *mut HeapEntry
}

pub struct Heap {
  root: *mut HeapEntry,
  limit: *mut u8
}

impl Heap {

  pub const fn empty() -> Heap {
    Heap {
      root: 0 as *mut HeapEntry,
      limit: 0 as *mut u8
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
        limit: start.offset(DEFAULT_SIZE as isize)
      }
    }
  }

  unsafe fn increase(&self, last: *mut HeapEntry, end: *mut HeapEntry) {
    const INCREASE_SIZE: usize = 0x1000;
    mmap(end as *mut u8, INCREASE_SIZE);
    (*end).used = false;
    (*end).size = INCREASE_SIZE - mem::size_of::<HeapEntry>();
    (*end).prev = last;
    debug!("HEAP INCREASE SIZE");
  }

  unsafe fn split_current(entry: *mut HeapEntry, size: usize) {
    const SPLIT_MARGIN: usize = 2; //The number of bytes left after a split before we bother saving them for later
    if (*entry).size - size > mem::size_of::<HeapEntry>() + SPLIT_MARGIN {
      let original_size = (*entry).size;
      (*entry).size = size;
      let after = (entry as *mut u8)
        .offset((mem::size_of::<HeapEntry>() + size) as isize) as *mut HeapEntry;
      (*after).size = original_size - size;
      (*after).prev = entry;
    }
  }

  pub unsafe fn alloc(&self, size: usize) -> *mut u8 {

    /** Find next free block **/
    let mut current = self.root;

    loop {

      if !(*current).used && (*current).size > size {
        break;
      }

      let last = current;
      current = (current as *mut u8).offset(((*current).size + mem::size_of::<HeapEntry>()) as isize) as *mut HeapEntry;

      if current as *mut u8 >= self.limit {
        self.increase(last, current);
      }
    }

    //Split if it is large enough to become 2 heap entries
    //Then mark it as used
    Heap::split_current(current, size);
    (*current).used = true;

    (current as *mut u8).offset(mem::size_of::<HeapEntry>() as isize)
  }

  unsafe fn merge_entry(entry: *mut HeapEntry) {
    debug!("TODO: Heap Merge");
  }

  pub unsafe fn free(&self, entry: *mut u8) {
    let entry = entry.offset(-(mem::size_of::<HeapEntry>() as isize)) as *mut HeapEntry;
    (*entry).used = false;
    Heap::merge_entry(entry);
  }
}
