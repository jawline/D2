macro_rules! debug {
    ( $msg:expr ) => {
		{	
      print!("[?] ");
			println!($msg);
    }
    };
		( $cnd:expr, $msg:expr ) => {
		{
			if !$condition { 
				debug!($msg);
			}
    }
    };
}

macro_rules! panic {
  ( $msg:expr ) => {
    {
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
