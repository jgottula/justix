%include 'common/header.inc'
%include 'core/main.inc'
	
	section .text
	
	global kern_die:function
kern_die:
	; TODO: wait a bit before disabling interrupts to allow serial to flush
	
	cli
	hlt
	
	jmp $
	
	
	section .bss
	
gdata kern_syscall_stack_top
	resb 0x1000
gdata kern_syscall_stack_bottom
