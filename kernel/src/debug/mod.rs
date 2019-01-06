macro_rules! debug {
		( $cnd:expr, $msg:expr ) => {
		{
			use io::print;
			if !$condition { 
				println!($msg);
			}
    }
};
}
