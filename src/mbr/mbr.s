%include 'common/header.s'
%include 'common/macro.s'
%include 'common/bios.s'
%include 'common/mbr.s'
	
%define MBR_OFFSET 0x0c00
	
	cpu 386
	bits 16
	
	org MBR_OFFSET
	section .text align=1
	
mbr_init:
	cli
	
	xor ax,ax
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	
	mov sp,0x7c00
	
	push dx
	
.move_mbr:
	mov si,0x7c00
	mov di,MBR_OFFSET
	mov cx,0x0200
	rep movsd
	
	jmp 0x0000:mbr_ready
	
mbr_ready:
	sti
	
	mov al,0x01
	
	mov ah,BIOS_VID_PAGE
	int BIOS_VID
	
	mov bh,0x01
	mov dx,0x0000
	
	mov ah,BIOS_VID_SETCUR
	int BIOS_VID
	
	mov cx,11
	mov bp,mbr_data.msg_hello
	call mbr_print_msg
	
	mov cx,4
	mov si,(MBR_OFFSET+MBR_PART1)
	
.part_loop:
	mov al,[ds:si]
	bt ax,7
	jc mbr_found_active
	
	add si,0x10
	loop .part_loop
	
.no_active:
	mov cx,16
	mov bp,mbr_data.msg_err_noactive
	call mbr_print_msg
	
	jmp mbr_stop
	
mbr_found_active:
	mov bp,sp
	mov dx,[bp]
	
	mov ah,BIOS_DISK_RESET
	int BIOS_DISK
	
	jnc .reset_ok
	
.reset_fail:
	mov cx,17
	mov bp,mbr_data.msg_err_reset
	call mbr_print_msg
	
	jmp mbr_stop
	
.reset_ok:
	mov al,0x01
	mov dh,[si+1]
	mov cx,[si+2]
	mov bx,0x7c00
	
	mov ah,BIOS_DISK_READ
	int BIOS_DISK
	
	jnc mbr_jump
	
.read_fail:
	mov cx,16
	mov bp,mbr_data.msg_err_read
	call mbr_print_msg
	
	jmp mbr_stop
	
mbr_jump:
	jmp 0x7c00
	
mbr_stop:
	cli
	hlt
	jmp mbr_stop
	
	; cx    length
	; es:bp string
mbr_print_msg:
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
	
	
mbr_data:
.msg_hello:
	db `JGSYS MBR\r\n`
.msg_err_noactive:
	db `NO ACTIVE PART\r\n`
.msg_err_reset:
	db `DISK RESET FAIL\r\n`
.msg_err_read:
	db `DISK READ FAIL\r\n`
	
mbr_fill:
	fill_to 0x1b8,0x00
