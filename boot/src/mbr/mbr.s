; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.


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
mbr_skip:
	jmp mbr_init
	
	; zero-fill the FAT/DOS region so we don't confuse DOS/Windows
mbr_bpb_fill:
	fill_to MBR_OFF_CODE,0x00
	
mbr_init:
	cli
	
	xor ax,ax
	mov ss,ax
	mov ds,ax
	mov es,ax
	
	mov sp,STACK_ADDR
	
	push dx
	
.move_mbr:
	cld
	mov si,MBR_ENTRY
	mov di,MBR_OFFSET
	mov cx,(MBR_SIZE/4)
	rep movsd
	
	jmp 0x0000:mbr_ready
	
mbr_ready:
	sti
	
	call boot_video_setup
	
	mov bp,mbr_data.msg_hello
	call boot_print_line
	
mbr_find_active:
	mov cx,4
	mov si,(MBR_OFFSET+MBR_OFF_PART1)
	
.part_loop:
	mov al,[si+MBR_PART_OFF_STATUS]
	test al,0x80
	jnz mbr_read_vbr
	
	add si,MBR_PART_SIZE
	loop .part_loop
	
.no_active:
	mov bp,mbr_data.msg_err_noactive
	call boot_print_line
	
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
	
	mov bx,STAGE1_OFFSET
	
	mov al,0x01
	
	mov ah,BIOS_DISK_READ
	int 0x13
	
	jnc mbr_jump
	
.read_fail:
	mov bp,mbr_data.msg_err_read
	call boot_print_line
	
	jmp mbr_stop
	
mbr_jump:
	jmp STAGE1_OFFSET
	
mbr_stop:
	cli
	hlt
	jmp mbr_stop
	
	
%define BOOT_CODE_VIDEO_SETUP
%define BOOT_CODE_PRINT_LINE
%define BOOT_CODE_LBA_TO_CHS
%include 'common/boot.s'
	
	
mbr_data:
.msg_hello:
	strz `justix mbr`
.msg_err_noactive:
	strz `No active partition`
.msg_err_read:
	strz `Read failed`
	
mbr_fill:
	fill_to MBR_CODE_SIZE,0x00
