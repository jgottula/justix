	extern kern_setup_idt
	
	cpu 586
	bits 32
	
	section .text
	
	global kern_entry
kern_entry:
	; PRIORITIES:
	; GDT
	; set segment registers
	; set up the stack
	; IDT (with exception handlers)
	; turn on interrupts
	
	call kern_setup_idt
	sti
	
	; for now, we'll just use unreal mode to say hi:
	mov edi,0xb9000
	mov word [es:edi],0x3000|'H'
	mov edi,0xb9002
	mov word [es:edi],0x0300|'i'
	
kern_stop:
	cli
	hlt
	jmp kern_stop
