%include 'common/header.inc'
%include 'core/main.inc'
	
	section .text
	
	global kern_die:function
kern_die:
	; TODO: wait a bit before disabling interrupts to allow serial to flush
	
	cli
	hlt
	
	jmp $
