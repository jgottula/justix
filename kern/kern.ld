OUTPUT_FORMAT(elf32-i386)

KERN_OFFSET = 0x00100000;

SECTIONS {
	ENTRY(kern_entry)
	
	.text.start (KERN_OFFSET) : {
		src/init.o(.text)
	}
	
	.text ALIGN (0x1000) : {
		*(.text)
	}
	
	.data ALIGN (0x1000) : {
		*(.data)
	}
	
	.rodata ALIGN (0x1000) : {
		*(.rodata)
	}
	
	.bss ALIGN (0x1000) : {
		*(.bss)
	}
}
