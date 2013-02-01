%include 'common/header.inc'
%include 'core/exception.inc'
%include 'lib/debug.inc'
	
	section .text
	
	global trap_gpf:function
trap_gpf:
	frame
	pushad
	
	invoke debug_write_str,str_gpf
	invoke debug_stack_trace,ebp
	
	mov word [0xb90a0],0x7000|'G'
	mov word [0xb90a2],0x7000|'P'
	mov word [0xb90a4],0x7000|'F'
	
	popad
	unframe
	iret
	
	
	section .rodata
	
str_gpf:
	strz `GPF!\n`
