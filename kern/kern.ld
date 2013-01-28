OUTPUT_FORMAT(elf32-i386)

KERN_OFFSET = 0x00100000;

SECTIONS {
	ENTRY(kern_entry)
	
	.text.start (KERN_OFFSET) : {
	_INIT_START = .;
		src/core/init.o(.text)
	_INIT_END = .;
	}
	
	.text ALIGN (0x1000) : {
	_INIT_START = .;
		*(.text)
	_INIT_END = .;
	}
	
	.data ALIGN (0x1000) : {
	_DATA_START = .;
		*(.data)
	_DATA_END = .;
	}
	
	.rodata ALIGN (0x1000) : {
	_RODATA_START = .;
		*(.rodata)
	_RODATA_END = .;
	}
	
	.bss ALIGN (0x1000) : {
	_BSS_START = .;
		*(.bss)
	_BSS_END = .;
	}
}
