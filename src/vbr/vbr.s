%include 'common/header.inc'
%include 'common/macro.inc'
%include 'common/boot.inc'
%include 'common/bios.inc'
%include 'common/jgfs.inc'
	
	cpu 386
	bits 16
	
	org VBR_OFFSET
	section .text align=1
	
	; from the mbr:
	; [sp] disk number
	;  si  partition entry
vbr_begin:
	push si
	
	mov cx,11
	mov bp,vbr_data.msg_hello
	call boot_print_msg
	
vbr_check_int13_ext:
	mov bp,sp
	mov dx,[bp+2]
	mov bx,BIOS_BOOT_FLAG
	
	mov ah,BIOS_DISK_EXT_CHK
	int BIOS_DISK
	
	jnc vbr_read_jgfs_hdr
	
.int13_ext_fail:
	mov cx,17
	mov bp,vbr_data.msg_err_ext
	call boot_print_msg
	jmp vbr_stop
	
vbr_read_jgfs_hdr:
	mov bp,sp
	mov si,[bp]
	
	push dword 0x00000000         ; block high
	push dword [si+8]             ; block low
	push dword JGFS_HDR_OFFSET    ; dest addr (seg:off)
	push word  0x0001             ; qty blocks
	push word  BIOS_DADDRPKT_SIZE ; size of packet
	
	inc dword [bp+8]
	
	mov dx,[bp+18]
	mov si,sp
	
	mov ah,BIOS_DISK_EXT_READ
	int BIOS_DISK
	
	jnc vbr_check_jgfs_hdr
	
.read_fail:
	mov cx,18
	mov bp,vbr_data.msg_err_read
	call boot_print_msg
	
	mov cx,15
	mov bp,vbr_data.msg_err_read_hdr
	call boot_print_msg
	
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
	
	jmp vbr_read_jgfs_rsvd
	
.check_fail:
	cmp cx,2
	jb .check_fail_version
	
.check_fail_magic:
	mov bp,vbr_data.msg_err_jgfs_magic
	mov cx,17
	jmp .check_fail_common
	
.check_fail_version:
	mov bp,vbr_data.msg_err_jgfs_version
	mov cx,28
	
.check_fail_common:
	call boot_print_msg
	jmp vbr_stop
	
vbr_read_jgfs_rsvd:
	mov bp,sp
	
	mov ax,[JGFS_HDR_OFFSET+JGFS_OFF_S_RSVD]
	mov [bp+2],ax                ; qty blocks: s_rsvd
	mov word  [bp+4],BOOT_OFFSET ; dest addr:  0000:8000
	inc dword [bp+8]             ; block low:  +1
	
	mov dx,[bp+18]
	mov si,sp
	
	mov ah,BIOS_DISK_EXT_READ
	int BIOS_DISK
	
	jnc vbr_jump
	
.read_fail:
	mov cx,18
	mov bp,vbr_data.msg_err_read
	call boot_print_msg
	
	mov cx,17
	mov bp,vbr_data.msg_err_read_rsvd
	call boot_print_msg
	
	jmp vbr_stop
	
vbr_jump:
	add sp,BIOS_DADDRPKT_SIZE
	pop si
	
	jmp BOOT_OFFSET
	
vbr_stop:
	cli
	hlt
	jmp vbr_stop
	
	
%include 'common/boot.s'
	
	
vbr_data:
.jgfs:
	db JGFS_MAGIC,JGFS_VER_MAJOR,JGFS_VER_MINOR
.msg_hello:
	db `JGSYS VBR\r\n`
.msg_err_ext:
	db `No LBA support!\r\n`
.msg_err_read:
	db `Disk read failed! `
.msg_err_read_hdr:
	db `(JGFS header)\r\n`
.msg_err_read_rsvd:
	db `(stage2 loader)\r\n`
.msg_err_jgfs_magic:
	db `JGFS not found!\r\n`
.msg_err_jgfs_version:
	db `Incompatible JGFS version!\r\n`
	
vbr_fill:
	fill_to VBR_OFF_BOOTFLAG,0x00
	
vbr_flag:
	dw_be BIOS_BOOT_FLAG
