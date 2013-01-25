%include 'common/header.s'
%include 'common/macro.s'
%include 'common/bios.s'
%include 'common/mbr.s'
	
	cpu 386
	bits 16
	
	org 0x7c00
	section .text align=1
	
mbr_init:
	cli
	jmp 0x0000:.adjust_cs
	
.adjust_cs:
	push dx
	
	xor ax,ax
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	
	mov sp,0x7c00
	sti
	
mbr_ready:
	mov dx,0x0000
	mov cx,11
	mov bp,mbr_data.msg_hello
	call mbr_print_msg
	
	mov cx,4
	mov si,MBR_PART1
	
.part_loop:
	mov al,[ds:si]
	bt ax,7
	jc mbr_found_active
	
	add si,0x10
	loop .part_loop
	
.no_active:
	mov dx,0x0100
	mov cx,16
	mov bp,mbr_data.msg_err_noactive
	call mbr_print_msg
	
	jmp mbr_stop
	
mbr_found_active:
	mov al,1
	mov dh,[ds:si+1]
	mov cx,[ds:si+2]
	mov bx,0x7e00
	
	mov ah,BIOS_DISK_READ
	int 0x13
	
	jnc mbr_jump
	
.read_fail:
	mov dx,0x0100
	mov cx,14
	mov bp,mbr_data.msg_err_read
	call mbr_print_msg
	
	jmp mbr_stop
	
mbr_jump:
	pop dx
	mov dh,[ds:si+1]
	push dx
	
	mov dx,[ds:si+2]
	push dx
	
	jmp 0x7e00
	
mbr_stop:
	cli
	hlt
	jmp mbr_stop
	
	
	; params:
	; cx length
	; dx row:col
	; bp src
mbr_print_msg:
	mov al,0b01 ; mode: advance cursor
	mov bh,0x00 ; page
	mov bl,BIOS_COLOR(LTGRAY, BLACK)
	
	mov ah,BIOS_VID_STR
	int 0x10
	
	ret
	
	
mbr_data:
.msg_hello:
	db `JGSYS MBR\r\n`
.msg_err_noactive:
	db `NO ACTIVE PART\r\n`
.msg_err_read:
	db `READ FAILURE\r\n`
	
mbr_fill:
	fill_to 0x1b8,0x00
