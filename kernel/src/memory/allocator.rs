use memory::Heap;
use core::alloc::{GlobalAlloc, Layout};
use core::cell::RefCell;

const KERNEL_HEAP_START: *mut u8 = 0x50000 as *mut u8;

pub struct KernelAllocator {
  heap: Option<RefCell<Heap>>
}

unsafe impl GlobalAlloc for KernelAllocator {

    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
      if let Some(heap) = &self.heap {
        heap.borrow_mut().alloc(layout.size())
      } else {
        0 as *mut u8
      }
    }

    unsafe fn dealloc(&self, ptr: *mut u8, _layout: Layout) {
      if let Some(heap) = &self.heap {
        heap.borrow_mut().free(ptr) 
      }
    }

}

impl KernelAllocator {

  pub const fn default() -> KernelAllocator {
    KernelAllocator {
      heap: None
    }
  }

  pub fn new(addr: *mut u8) -> KernelAllocator {
    KernelAllocator {
      heap: Some(RefCell::new(Heap::new(addr)))
    }
  }

}

pub fn init(allocator: &mut KernelAllocator) {
  *allocator = KernelAllocator::new(KERNEL_HEAP_START);
}
