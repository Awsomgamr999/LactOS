ENTRY(kernel_entry)

SECTIONS
{
	. = 0x1000;

	.text : {
		KEEP(*(.text))
		*(.text.*)
	}

	.rodata : {
		*(.rodata)
		*(.rodata.*)
	}

	.data : {
		*(.data)
		*(.data.*)
	}

	.bss : {
		*(.bss)
		*(.bss.*)
		*(COMMON)
	}
}
