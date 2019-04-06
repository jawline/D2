#[macro_export]
macro_rules! println {
    ( $x:expr ) => {
        {
            use io::serial::{Serial, SERIAL_PORT};
            use io::stream::write;

            let serial = Serial::new(SERIAL_PORT);
            write(&serial, ($x).as_bytes());
            write(&serial, "\r\n".as_bytes());
        }
    };
}
