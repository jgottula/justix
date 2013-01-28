%include 'common/header.inc'
	
	section .text
	
	global trap_gpf:function
trap_gpf:
	mov word [0xb9006],0x7000|'G'
	mov word [0xb9008],0x7000|'P'
	mov word [0xb900a],0x7000|'F'
	
	iret
