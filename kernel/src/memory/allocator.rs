use memory::Heap;
use core::alloc::{GlobalAlloc, Layout};
use core::cell::RefCell;

const KERNEL_HEAP_START: *mut u8 = 0x50000 as *mut u8;

pub struct KernelAllocator {
  heap: RefCell<Heap>
}

unsafe impl GlobalAlloc for KernelAllocator {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 { self.heap.borrow_mut().alloc(layout.size()) }
    unsafe fn dealloc(&self, ptr: *mut u8, _layout: Layout) { self.heap.borrow_mut().free(ptr) }
}

impl KernelAllocator {
  pub const fn empty() -> KernelAllocator {
    KernelAllocator {
      heap: RefCell::new(Heap::empty())
    }
  }

  pub fn new(addr: *mut u8) -> KernelAllocator {
    KernelAllocator {
      heap: RefCell::new(Heap::new(addr))
    }
  }
}

pub fn init(allocator: &mut KernelAllocator) {
  unsafe {
    *allocator = KernelAllocator::new(KERNEL_HEAP_START);
  }
}
