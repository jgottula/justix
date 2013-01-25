%include 'common/header.inc'
%include 'common/macro.inc'
%include 'common/boot.inc'
%include 'common/bios.inc'
	
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
	call boot_print_msg
	
	mov cx,4
	mov si,(MBR_OFFSET+MBR_OFF_PART1)
	
.part_loop:
	mov al,[ds:si]
	bt ax,7
	jc mbr_found_active
	
	add si,MBR_PART_SIZE
	loop .part_loop
	
.no_active:
	mov cx,22
	mov bp,mbr_data.msg_err_noactive
	call boot_print_msg
	
	jmp mbr_stop
	
mbr_found_active:
	mov bp,sp
	mov dx,[bp]
	
	mov ah,BIOS_DISK_RESET
	int BIOS_DISK
	
	jnc mbr_read_vbr
	
.reset_fail:
	mov cx,20
	mov bp,mbr_data.msg_err_reset
	call boot_print_msg
	
	jmp mbr_stop
	
mbr_read_vbr:
	mov al,0x01
	mov dh,[si+1]
	mov cx,[si+2]
	mov bx,VBR_OFFSET
	
	mov ah,BIOS_DISK_READ
	int BIOS_DISK
	
	jnc mbr_jump
	
.read_fail:
	mov cx,19
	mov bp,mbr_data.msg_err_read
	call boot_print_msg
	
	jmp mbr_stop
	
mbr_jump:
	jmp VBR_OFFSET
	
mbr_stop:
	cli
	hlt
	jmp mbr_stop
	
	
%include 'common/boot.s'
	
	
mbr_data:
.msg_hello:
	db `JGSYS MBR\r\n`
.msg_err_noactive:
	db `No active partition!\r\n`
.msg_err_reset:
	db `Disk reset failed!\r\n`
.msg_err_read:
	db `Disk read failed!\r\n`
	
mbr_fill:
	fill_to MBR_OFF_PTABLE,0x00
