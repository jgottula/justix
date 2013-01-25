%include 'common/header.s'
%include 'common/macro.s'
%include 'common/bios.s'
%include 'common/jgfs.s'
	
%define BOOT_OFFSET 0x8000
	
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
	
	
	
boot_stop:
	cli
	hlt
	jmp boot_stop
	
	
	; cx    length
	; es:bp string
boot_print_msg:
	mov bh,0x01
	
	push cx
	mov ah,BIOS_VID_GETCUR
	int BIOS_VID
	pop cx
	
	mov al,0x01
	mov bh,0x01
	mov bl,BIOS_COLOR(LTGRAY, BLACK)
	
	mov ah,BIOS_VID_STR
	int BIOS_VID
	
	ret
	
	
boot_data:
.msg_hello:
	db `JGSYS BOOT\r\n`
	
boot_fill:
	fill_to 0x1000,0x00
