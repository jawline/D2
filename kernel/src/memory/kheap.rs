use memory::Heap;

const KERNEL_HEAP_START: *mut u8 = 0x50000 as *mut u8;
static mut KERNEL_HEAP: Heap = Heap::empty();

pub fn init() {
  unsafe {
    KERNEL_HEAP = Heap::new(KERNEL_HEAP_START);
  }
}

pub fn kmalloc(size: usize) -> *mut u8 {
  unsafe {
    KERNEL_HEAP.alloc(size)
  }
}

pub fn kfree(ptr: *mut u8) {
  unsafe {
    KERNEL_HEAP.free(ptr)
  }
}
