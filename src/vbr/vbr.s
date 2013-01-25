%include 'common/header.s'
%include 'common/macro.s'
%include 'common/bios.s'
%include 'common/jgfs.s'
	
%define VBR_OFFSET 0x7c00
	
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
	call vbr_print_msg
	
vbr_check_int13_ext:
	mov bp,sp
	mov dx,[bp+2]
	mov bx,0x55aa
	
	mov ah,BIOS_DISK_EXT_CHK
	int BIOS_DISK
	
	jnc vbr_read_jgfs_hdr
	
.int13_ext_fail:
	mov cx,17
	mov bp,vbr_data.msg_err_ext
	call vbr_print_msg
	jmp vbr_stop
	
vbr_read_jgfs_hdr:
	push dword 0x00000000 ; block high
	push dword [si+8]     ; block low
	push dword 0x00007e00 ; dest addr (seg:off)
	push word  0x0001     ; qty blocks
	push word  0x0010     ; size of packet
	
	mov bp,sp
	inc dword [bp+8]
	
	mov dx,[bp+18]
	mov si,sp
	
	mov ah,BIOS_DISK_EXT_READ
	int BIOS_DISK
	
	jnc vbr_check_jgfs_hdr
	
.read_fail:
	mov cx,22
	mov bp,vbr_data.msg_err_read_hdr
	call vbr_print_msg
	jmp vbr_stop
	
vbr_check_jgfs_hdr:
	mov si,0x7e00
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
	mov cx,16
	jmp .check_fail_common
	
.check_fail_version:
	mov bp,vbr_data.msg_err_jgfs_version
	mov cx,18
	
.check_fail_common:
	call vbr_print_msg
	jmp vbr_stop
	
vbr_read_jgfs_rsvd:
	mov bp,sp
	mov ax,[0x7e0a]
	mov [bp+2],ax           ; qty blocks: s_rsvd
	mov word  [bp+4],0x8000 ; dest addr:  0000:8000
	inc dword [bp+8]        ; block low:  +1
	
	mov dx,[bp+18]
	mov si,sp
	
	mov ah,BIOS_DISK_EXT_READ
	int BIOS_DISK
	
	jnc vbr_jump
	
.read_fail:
	mov cx,23
	mov bp,vbr_data.msg_err_read_rsvd
	call vbr_print_msg
	jmp vbr_stop
	
vbr_jump:
	add sp,0x10
	pop si
	
	jmp 0x8000
	
vbr_stop:
	cli
	hlt
	jmp vbr_stop
	
	
	; cx    length
	; es:bp string
vbr_print_msg:
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
	
	
vbr_data:
.jgfs:
	db `JGFS`,0x03,0x00
.msg_hello:
	db `JGSYS VBR\r\n`
.msg_err_ext:
	db `NO INT 0x13 EXT\r\n`
.msg_err_read_hdr:
	db `DISK READ FAIL (HDR)\r\n`
.msg_err_read_rsvd:
	db `DISK READ FAIL (RSVD)\r\n`
.msg_err_jgfs_magic:
	db `JGFS NOT FOUND\r\n`
.msg_err_jgfs_version:
	db `JGFS BAD VERSION\r\n`
	
vbr_fill:
	fill_to 0x1fe,0x00
	
vbr_flag:
	db 0x55
	db 0xaa
