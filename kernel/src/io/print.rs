

macro_rules! println {
    ( $x:expr ) => {
        {
            use io::serial::Serial;
            use io::stream::{OutStream, write};

            let serial = Serial::new();
            write(&serial, ($x).as_bytes());
            write(&serial, "\r\n".as_bytes());
        }
    };
}

