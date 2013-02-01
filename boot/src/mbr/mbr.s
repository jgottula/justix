%include 'common/header.inc'
%include 'common/macro.inc'
%include 'common/boot.inc'
%include 'common/bios.inc'
%include 'common/video.inc'
	
	cpu 386
	bits 16
	
	org MBR_OFFSET
	section .text align=1
	
	; from the bios:
	; DL boot disk
mbr_init:
	cli
	
	xor ax,ax
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	
	mov sp,STACK_ADDR
	
	push dx
	
.move_mbr:
	cld
	mov si,MBR_ENTRY
	mov di,MBR_OFFSET
	mov cx,MBR_SIZE
	rep movsd
	
	jmp 0x0000:mbr_ready
	
mbr_ready:
	sti
	
	mov al,0x01
	
	mov ah,BIOS_VID_PAGE
	int 0x10
	
	mov bh,0x01
	mov dx,0x0000
	
	mov ah,BIOS_VID_SETCUR
	int 0x10
	
	mov cx,11
	mov bp,mbr_data.msg_hello
	call boot_print_str
	
mbr_find_active:
	mov cx,4
	mov si,(MBR_OFFSET+MBR_OFF_PART1)
	
.part_loop:
	mov al,[si]
	bt ax,7
	jc mbr_read_vbr
	
	add si,MBR_PART_SIZE
	loop .part_loop
	
.no_active:
	mov cx,22
	mov bp,mbr_data.msg_err_noactive
	call boot_print_str
	
	jmp mbr_stop
	
mbr_read_vbr:
	pop dx
	push dx
	
	mov ah,BIOS_DISK_PARAM
	int 0x13
	
	pop bx
	mov dl,bl
	
	and cl,0x3f
	inc dh
	
	mov eax,[si+MBR_PART_OFF_LBA]
	call boot_lba_to_chs
	
	mov bx,VBR_OFFSET
	
	mov al,0x01
	
	mov ah,BIOS_DISK_READ
	int 0x13
	
	jnc mbr_jump
	
.read_fail:
	mov cx,19
	mov bp,mbr_data.msg_err_read
	call boot_print_str
	
	jmp mbr_stop
	
mbr_jump:
	jmp VBR_OFFSET
	
mbr_stop:
	cli
	hlt
	jmp mbr_stop
	
	
%define BOOT_CODE_PRINT_STR
%define BOOT_CODE_LBA_TO_CHS
%include 'common/boot.s'
	
	
mbr_data:
.msg_hello:
	db `JGSYS MBR\r\n`
.msg_err_noactive:
	db `No active partition!\r\n`
.msg_err_param:
	db `Disk param failed!\r\n`
.msg_err_read:
	db `Disk read failed!\r\n`
	
mbr_fill:
	fill_to MBR_CODE_SIZE,0x00
