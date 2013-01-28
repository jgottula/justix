	global kern_setup_idt
kern_setup_idt:
	lidt [idt.info]
	
	ret
	
isr_doublefault:
	
	iret
	
isr_gpfault:
	
	iret
	
idt:
.int00: dq 0
.int01: dq 0
.int02: dq 0
.int03: dq 0
.int04: dq 0
.int05: dq 0
.int06: dq 0
.int07: dq 0
.int08:
	dw ((isr_doublefault-$$) & 0xffff)
	dw 0x10
	db 0x00
	db 0b10001111
	dw (((isr_doublefault-$$) >> 16) & 0xffff)
.int09: dq 0
.int0a: dq 0
.int0b: dq 0
.int0c: dq 0
.int0d:
	dw ((isr_gpfault-$$) & 0xffff)
	dw 0x10
	db 0x00
	db 0b10001111
	dw (((isr_gpfault-$$) >> 16) & 0xffff)
.int0e: dq 0
.int0f: dq 0
.int10: dq 0
.int11: dq 0
.int12: dq 0
.int13: dq 0
.int14: dq 0
.int15: dq 0
.int16: dq 0
.int17: dq 0
.int18: dq 0
.int19: dq 0
.int1a: dq 0
.int1b: dq 0
.int1c: dq 0
.int1d: dq 0
.int1e: dq 0
.int1f: dq 0
.end:
.info:
	dw (.end-idt)-1
	dd idt
