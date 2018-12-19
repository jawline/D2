#[repr(C)]
struct SmapEntry {
  address: u64,
	length: u64,
	entry_type: u32,
	acpi_bf: u32
}

pub fn init(start: *const u8) {
	let mut seen = 0;

	unsafe {
		let mut iterator = smap as *const SmapEntry;

		while (*iterator).length != 0 {
			let entry = smap as *const SmapEntry;



			seen += 1;
			iterator = iterator.add(1);
		}

		println!("SMAP Scanned");
	}

	let mut byte_buffer = [0 as u8; 512];
	util::itoa_bytes(seen, 16, &mut byte_buffer);
	println!(str::from_utf8(&mut byte_buffer).unwrap());
}
