%include 'common/header.s'
%include 'common/macro.s'

	cpu 386
	bits 16
	
	
	org 0x7c00
	section .text align=1
	
	; code here ::::
	
	fill_to 0x1fe,0x00
	
	; bootable flag
	db 0x55
	db 0xaa
