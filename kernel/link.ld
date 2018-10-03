OUTPUT_FORMAT("binary")
ENTRY("_entry")
_KERNEL_BASE_ = 0x10000;

SECTIONS {

    .text : AT(_KERNEL_BASE_) {
        _TEXT_START_ = .;
        *(.text)
        _TEXT_END_ = .; 
        . = ALIGN(0x1000);
    } 

    .data : AT(ADDR(.text) + SIZEOF(.text)) {
        _DATA_START_ = .;
        *(.data)
        _DATA_END_ = .; 
        . = ALIGN(0x1000);
    }

    .bss : AT(ADDR(.data) + SIZEOF(.data)) {
        _BSS_START_ = .;
        *(.bss)
        _BSS_END_ = .;
        . = ALIGN(0x1000);
    }
}
