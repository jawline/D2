OUTPUT_FORMAT("binary")
ENTRY("_entry")
_KERNEL_BASE_ = 0x10000;

SECTIONS {


    . = _KERNEL_BASE_;

    .text {
        *(.text)
    } 

    .data {
        *(.data)
    }

    .bss {
        *(.bss)
    }
}
