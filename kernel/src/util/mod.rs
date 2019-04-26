pub mod c_utilities;

macro_rules! offset_bytes {
    ($ty:ty, $field:expr, $offset: expr) => {
        ($field as *mut u8).offset($offset as isize) as *mut $ty
    }
}

pub fn itoa_bytes(v: i32, base: i32, dst: &mut [u8]) -> bool {

    if dst.len() < 2 {
        return false;
    }

    //Special case for 0
    if v == 0 {
        dst[0] = '0' as u8;
        dst[1] = '\0' as u8;
        return true;
    }

    let mut v = v;
    let mut idx = 0;

    while v != 0 && idx < dst.len() - 1 {
        let rem = v % base;

        dst[idx] = if rem > 9 {
          (rem - 10) as u8 + ('a' as u8)
        } else {
          ('0' as u8) + rem as u8
        };

        idx += 1;
        v = v / base;
    }

    dst[idx] = '\0' as u8;

    true
}
