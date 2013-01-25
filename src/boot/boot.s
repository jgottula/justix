%include 'common/header.inc'
%include 'common/macro.inc'
%include 'common/boot.inc'
%include 'common/bios.inc'
%include 'common/jgfs.inc'
	
	cpu 386
	bits 16
	
	org BOOT_OFFSET
	section .text align=1
	
	; from the mbr:
	; [sp] disk number
	;  si  partition entry
boot_begin:
	mov cx,12
	mov bp,boot_data.msg_hello
	call boot_print_msg
	
boot_find_mem:
	
	
boot_stop:
	cli
	hlt
	jmp boot_stop
	
	
%include 'common/boot.s'
	
	
boot_data:
.msg_hello:
	db `JGSYS BOOT\r\n`
	
boot_fill:
	fill_to BOOT_SIZE,0x00
