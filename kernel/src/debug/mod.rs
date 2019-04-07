macro_rules! debug {
    ( $msg:expr ) => {
		{	
      use io::print;
      print!("[?] ");
			println!($msg);
    }
    };
		( $cnd:expr, $msg:expr ) => {
		{
			use io::print;
			if !$condition { 
				debug!($msg);
			}
    }
    };
}

macro_rules! panic {
  ( $msg:expr ) => {
    {
      use io::print;
      print!("[!!] KERNEL PANIC: ");
      println!($msg);
      loop {}
    }
  };
}

macro_rules! assert {
  ( $cnd:expr, $msg:expr ) => {
    {
      if !$cnd {
        panic!($msg);
      }
    }
  };
}
