pub struct Stack<T: Copy + Clone> {
	pub current: isize,
	pub limit: isize,
	pub entries: *mut T
}

impl <T: Copy + Clone>Stack<T> {
	pub fn new(address: *mut T) -> Stack<T> {
		Stack {
			current: 0,
			limit: 0,
			entries: address as *mut T
		}
	}

	pub fn push(&mut self, item: T) {
		assert!(self.current < self.limit, "Kernel Stack Push: No Memory");
		unsafe { (*self.entries.offset(self.current)) = item; }
		self.current += 1;
	}

	pub fn pop(&mut self) -> T {
		assert!(self.current > 0, "Kernel Stack Pop: No Entries");
		self.current -= 1;
		unsafe { (*self.entries.offset(self.current)) }
	}
}
