use memory::mmap;

const HEAP_MAGIC: u8 = 0xAF;

struct HeapEntry {
  magic: u8,
  used: bool,
  next: *mut HeapEntry,
  prev: *mut HeapEntry
}

pub struct Heap {
  root: *mut HeapEntry,
  limit: usize
}

impl Heap {
  pub fn new(start: *mut u8) -> Heap {

    mmap(start, 0x10000);

    let root_entry = start as *mut HeapEntry;

    unsafe {
      (*root_entry).magic = HEAP_MAGIC;
      (*root_entry).used = false;
      (*root_entry).prev = 0 as *mut HeapEntry;
      (*root_entry).next = 0 as *mut HeapEntry;
    }

    Heap {
      root: root_entry,
      limit: 0x10000
    }
  }

  pub fn alloc(size: usize) -> *mut u8 { 0 as *mut u8 }
  pub fn free(entry: *mut u8) {}
}
