#[macro_export]
macro_rules! print {
    ( $x:expr ) => {
        {
            use io::serial::{Serial, SERIAL_PORT};
            use io::stream::write;

            let serial = Serial::new(SERIAL_PORT);
            write(&serial, ($x).as_bytes());
        }
    };
}

#[macro_export]
macro_rules! print_endl {
    ( ) => {
        {
            use io::serial::{Serial, SERIAL_PORT};
            use io::stream::write;

            let serial = Serial::new(SERIAL_PORT);
            write(&serial, "\r\n".as_bytes());
        }
    };
}

#[macro_export]
macro_rules! println {
    ( $x:expr ) => {
        {
          print!($x);
          print_endl!();
        }
    };
}
