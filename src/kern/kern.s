%include 'common/boot.inc'
%include 'common/video.inc'
	
	cpu 586
	bits 32
	
	org KERN_OFFSET
	section .text align=1
	
kern_init:
	; TODO:
	; set up IDT and GDT
	
	; for now, we'll just use unreal mode to say hi:
	mov edi,0xb9000
	mov word [fs:edi],(COLOR(LTGRAY, BLACK)<<8)|'H'
	mov edi,0xb9002
	mov word [fs:edi],(COLOR(LTGRAY, BLACK)<<8)|'i'
	
kern_stop:
	cli
	hlt
	jmp kern_stop
