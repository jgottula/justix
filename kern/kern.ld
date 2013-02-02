OUTPUT_FORMAT(elf32-i386)

KERN_OFFSET = 0x00100000;

ENTRY(kern_entry)

SECTIONS {
	.text.init (KERN_OFFSET) : {
	_INIT_START = .;
		*(.text.init)
	_INIT_END = .;
	}
	
	.text ALIGN (0x1000) : {
	_TEXT_START = .;
		*(.text)
	_TEXT_END = .;
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
	
	_BSS_SIZE = _BSS_END - _BSS_START;
}
