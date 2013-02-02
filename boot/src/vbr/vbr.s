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
	
	mov sp,STACK_ADDR
	
vbr_ready:
	sti
	
	call boot_video_setup
	
	mov bp,vbr_data.msg_hello
	call boot_print_line
	
	; TODO: handle recent windows mbr which puts part entry in ds:bp
	
	; if si is zero, we probably didn't come from an mbr
	or si,si
	jz vbr_no_mbr
	
	; if we can't find the boot flag, we probably didn't come from an mbr
	test byte [si+MBR_PART_OFF_STATUS],0x80
	jz vbr_no_mbr
	
	jmp vbr_load_param
	
vbr_no_mbr:
	; if there is no mbr, fake a partition entry
	sub sp,MBR_PART_SIZE
	mov si,sp
	
	xor eax,eax
	mov [si+MBR_PART_OFF_LBA],eax
	
vbr_load_param:
	push si
	push dx
	push es
	
	mov ah,BIOS_DISK_PARAM
	int 0x13
	
	jnc .param_ok
	
.param_fail:
	mov bp,vbr_data.msg_err_param
	call boot_print_line
	
	jmp vbr_stop
	
.param_ok:
	pop es
	
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
	mov bp,vbr_data.msg_err_read
	call boot_print_line
	
	mov bp,vbr_data.msg_err_read_hdr
	call boot_print_line
	
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
	mov bp,vbr_data.msg_err_jgfs_magic
	jmp .check_fail_common
	
.check_fail_version:
	mov bp,vbr_data.msg_err_jgfs_version
	
.check_fail_common:
	call boot_print_line
	jmp vbr_stop
	
vbr_check_s_boot:
	mov ax,[JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_BOOT]
	cmp ax,(STAGE2_SIZE / 0x200)
	
	jae vbr_read_stage2
	
.fail:
	mov bp,vbr_data.msg_err_jgfs_s_boot
	call boot_print_line
	
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
	mov bp,vbr_data.msg_err_read
	call boot_print_line
	
	mov bp,vbr_data.msg_err_read_stage2
	call boot_print_line
	
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
%define BOOT_CODE_PRINT_LINE
%define BOOT_CODE_LBA_TO_CHS
%include 'common/boot.s'
	
	
vbr_data:
.jgfs:
	db JGFS_MAGIC,JGFS_VER_MAJOR,JGFS_VER_MINOR
.msg_hello:
	strz `JGSYS VBR`
.msg_err_param:
	strz `Param failed`
.msg_err_read:
	strz `Read failed:`
.msg_err_read_hdr:
	strz `JGFS header`
.msg_err_read_stage2:
	strz `stage2 loader`
.msg_err_jgfs_magic:
	strz `JGFS missing`
.msg_err_jgfs_version:
	strz `JGFS incompatible`
.msg_err_jgfs_s_boot:
	strz `stage2 missing`
.param_sect:
	db 0x00
.param_head:
	db 0x00
	
vbr_fill:
	fill_to VBR_OFF_BOOTFLAG,0x00
	
vbr_flag:
	dw_be BIOS_BOOT_FLAG
