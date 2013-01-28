%include 'common/boot.inc'
%include 'common/video.inc'
	
	cpu 586
	bits 32
	
	org KERN_OFFSET
	section .text align=1
	
kern_init:
	; TODO:
	; note that interrupts are off upon entry
	; set up IDT and GDT
	; set segment registers
	; get a stack going
	
	; for now, we'll just use unreal mode to say hi:
	mov edi,0xb9000
	mov word [es:edi],(COLOR(LTGRAY, BLACK)<<8)|'H'
	mov edi,0xb9002
	mov word [es:edi],(COLOR(LTGRAY, BLACK)<<8)|'i'
	
kern_stop:
	cli
	hlt
	jmp kern_stop
