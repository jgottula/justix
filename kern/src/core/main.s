; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.


%include 'common/header.inc'
%include 'core/main.inc'
%include 'serial/serial.inc'
	
	section .text
	
	global kern_die:function
kern_die:
	invoke serial_flush
	
	;cli
	hlt
	
	jmp $
	
	
func user_test
	
	nop
	nop
	nop
	nop
	int 0x80
	
	;jmp $
	
func_end
	
	
	section .bss
	
gdata kern_syscall_stack_top
	resb 0x1000
gdata kern_syscall_stack_bottom
