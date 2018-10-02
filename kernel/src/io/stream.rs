pub trait OutStream {
    fn putc(&self, c: u8);
}

pub fn write<T: OutStream>(stream: &T, data: &[u8]) {
    for i in 0..data.len() {
        stream.putc(data[i]);
    }
}
