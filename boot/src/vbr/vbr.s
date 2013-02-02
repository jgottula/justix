%include 'common/header.inc'
%include 'common/macro.inc'
%include 'common/boot.inc'
%include 'common/bios.inc'
%include 'common/video.inc'
%include 'common/jgfs.inc'
	
	cpu 386
	bits 16
	
	org VBR_OFFSET
	section .text align=1
	
	; from the mbr:
	; DL boot disk
	; SI partition entry
vbr_begin:
	cli
	
	xor ax,ax
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	
	mov sp,STACK_ADDR
	
vbr_ready:
	sti
	
	call boot_video_setup
	
	mov cx,11
	mov bp,vbr_data.msg_hello
	call boot_print_str
	
vbr_load_param:
	push si
	push dx
	
	mov ah,BIOS_DISK_PARAM
	int 0x13
	
	and cl,0x3f
	mov [vbr_data.param_sect],cl
	
	inc dh
	mov [vbr_data.param_head],dh
	
	pop bx
	mov dl,bl
	
vbr_read_jgfs_hdr:
	mov eax,[si+MBR_PART_OFF_LBA]
	inc eax
	
	call boot_lba_to_chs
	
	mov al,0x01
	
	mov bx,JGFS_HDR_OFFSET
	
	mov ah,BIOS_DISK_READ
	int 0x13
	
	jnc vbr_check_jgfs_hdr
	
.read_fail:
	mov cx,18
	mov bp,vbr_data.msg_err_read
	call boot_print_str
	
	mov cx,15
	mov bp,vbr_data.msg_err_read_hdr
	call boot_print_str
	
	jmp vbr_stop
	
vbr_check_jgfs_hdr:
	mov si,JGFS_HDR_OFFSET
	mov di,vbr_data.jgfs
	mov cx,6
	
.check_loop:
	mov al,[si]
	cmp al,[di]
	
	jne .check_fail
	
	inc si
	inc di
	
	loop .check_loop
	
	jmp vbr_check_s_boot
	
.check_fail:
	cmp cx,2
	jb .check_fail_version
	
.check_fail_magic:
	mov cx,17
	mov bp,vbr_data.msg_err_jgfs_magic
	jmp .check_fail_common
	
.check_fail_version:
	mov cx,28
	mov bp,vbr_data.msg_err_jgfs_version
	
.check_fail_common:
	call boot_print_str
	jmp vbr_stop
	
vbr_check_s_boot:
	mov ax,[JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_BOOT]
	cmp ax,(STAGE2_SIZE / 0x200)
	
	jae vbr_read_stage2
	
.fail:
	mov cx,41
	mov bp,vbr_data.msg_err_jgfs_s_boot
	call boot_print_str
	
	jmp vbr_stop
	
vbr_read_stage2:
	pop si
	
	mov cl,[vbr_data.param_sect]
	mov dh,[vbr_data.param_head]
	
	mov eax,[si+MBR_PART_OFF_LBA]
	add eax,JGFS_BOOT_SECT
	
	call boot_lba_to_chs
	
	mov ax,[JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_BOOT]
	
	mov bx,STAGE2_OFFSET
	
	mov ah,BIOS_DISK_READ
	int 0x13
	
	jnc vbr_jump
	
.read_fail:
	mov cx,18
	mov bp,vbr_data.msg_err_read
	call boot_print_str
	
	mov cx,18
	mov bp,vbr_data.msg_err_read_stage2
	call boot_print_str
	
	jmp vbr_stop
	
vbr_jump:
	mov ch,[vbr_data.param_head]
	mov cl,[vbr_data.param_sect]
	
	jmp STAGE2_OFFSET
	
vbr_stop:
	cli
	hlt
	jmp vbr_stop
	
	
%define BOOT_CODE_VIDEO_SETUP
%define BOOT_CODE_PRINT_STR
%define BOOT_CODE_LBA_TO_CHS
%include 'common/boot.s'
	
	
vbr_data:
.jgfs:
	db JGFS_MAGIC,JGFS_VER_MAJOR,JGFS_VER_MINOR
.msg_hello:
	db `JGSYS VBR\r\n`
.msg_err_read:
	db `Disk read failed! `
.msg_err_read_hdr:
	db `(JGFS header)\r\n`
.msg_err_read_stage2:
	db `(stage 2 loader)\r\n`
.msg_err_jgfs_magic:
	db `JGFS not found!\r\n`
.msg_err_jgfs_version:
	db `Incompatible JGFS version!\r\n`
.msg_err_jgfs_s_boot:
	db `Boot area too small for stage 2 loader!\r\n`
.param_sect:
	db 0x00
.param_head:
	db 0x00
	
vbr_fill:
	fill_to VBR_OFF_BOOTFLAG,0x00
	
vbr_flag:
	dw_be BIOS_BOOT_FLAG
