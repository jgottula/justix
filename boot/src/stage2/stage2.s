%include 'common/header.inc'
%include 'common/macro.inc'
%include 'common/boot.inc'
%include 'common/bios.inc'
%include 'common/video.inc'
%include 'common/gdt.inc'
%include 'common/jgfs.inc'
	
	cpu 386
	bits 16
	
	org STAGE2_OFFSET
	section .text align=1
	
	; from the vbr:
	; CH heads/cylinder
	; CL sectors/track
	; DL boot disk
	; SI partition entry
stage2_begin:
	mov [stage2_data.param_head],ch
	mov [stage2_data.param_sect],cl
	
	mov [stage2_data.boot_disk],dx
	mov [stage2_data.boot_part_entry],si
	
	mov cx,14
	mov bp,stage2_data.msg_hello
	call boot_print_str
	
stage2_enable_a20:
	call stage2_test_a20
	jnc stage2_find_mem
	
	call stage2_enable_a20_bios
	call stage2_test_a20
	jnc stage2_find_mem
	
	call stage2_enable_a20_fast
	call stage2_test_a20
	jnc stage2_find_mem
	
	; not implemented: 8042 a20 enable
	
.fail:
	mov cx,32
	mov bp,stage2_data.msg_err_a20
	call boot_print_str
	
	jmp stage2_stop
	
stage2_find_mem:
	call stage2_mem_e820
	jnc stage2_load_kernel
	
	call stage2_mem_int12
	jc .mem_fail
	
	call stage2_mem_e881_e801
	jnc stage2_load_kernel
	
	; not implemented: int 0x15 ah=0x88
	
.mem_fail:
	mov cx,34
	mov bp,stage2_data.msg_err_mem
	call boot_print_str
	
	jmp stage2_stop
	
stage2_load_kernel:
	call stage2_enter_unreal
	
	call stage2_jgfs_fat_init
	
.fat_load_ok:
	movzx eax,word [JGFS_HDR_OFFSET+JGFS_HDR_OFF_ROOT_DE+JGFS_DE_OFF_BEGIN]
	mov edi,JGFS_CLUST_OFFSET
	
	call stage2_jgfs_read_clust
	jnc .root_clust_ok
	
.root_clust_fail:
	mov cx,38
	mov bp,stage2_data.msg_err_jgfs_root_dc
	call boot_print_str
	
	jmp stage2_stop
	
.root_clust_ok:
	mov ebp,stage2_data.kern_filename
	call stage2_jgfs_lookup_child
	
	jnc .found_kern
	
.not_found:
	mov cx,28
	mov bp,stage2_data.msg_err_jgfs_kern_lookup
	call boot_print_str
	
	jmp stage2_stop
	
.found_kern:
	mov ax,[ebp+JGFS_DE_OFF_TYPE]
	cmp ax,JGFS_TYPE_FILE
	
	je .type_ok
	
.type_fail:
	mov cx,27
	mov bp,stage2_data.msg_err_jgfs_kern_type
	call boot_print_str
	
	jmp stage2_stop
	
.type_ok:
	mov esi,ebp
	mov edi,KERN_OFFSET
	
	call stage2_jgfs_read_file
	
	jnc stage2_enter_kernel
	
.load_fail:
	mov cx,28
	mov bp,stage2_data.msg_err_jgfs_kern_load
	call boot_print_str
	
	cmp al,JGFS_ERR_INT13
	je .load_fail_int13
	
	cmp al,JGFS_ERR_BOUNDS_SECT
	je .load_fail_bounds_sect
	
	cmp al,JGFS_ERR_BOUNDS_FAT
	je .load_fail_bounds_fat
	
	cmp al,JGFS_ERR_FAT_CHAIN
	je .load_fail_fat_chain
	
	jmp .load_fail_unknown
	
.load_fail_int13:
	mov cx,13
	mov bp,stage2_data.msg_jgfs_err_int13
	
	jmp .load_fail_rejoin
	
.load_fail_bounds_sect:
	mov cx,29
	mov bp,stage2_data.msg_jgfs_err_bounds_sect
	
	jmp .load_fail_rejoin
	
.load_fail_bounds_fat:
	mov cx,26
	mov bp,stage2_data.msg_jgfs_err_bounds_fat
	
	jmp .load_fail_rejoin
	
.load_fail_fat_chain:
	mov cx,16
	mov bp,stage2_data.msg_jgfs_err_fat_chain
	
	jmp .load_fail_rejoin
	
.load_fail_unknown:
	mov cx,21
	mov bp,stage2_data.msg_jgfs_err_unknown
	
.load_fail_rejoin:
	call boot_print_str
	
.load_fail_done:
	jmp stage2_stop
	
stage2_enter_kernel:
	cli
	
	; enter protected mode
	mov eax,cr0
	or al,0x01
	mov cr0,eax
	
	; long jump into the kernel
	jmp 0x10:0x0000
	
stage2_stop:
	cli
	hlt
	jmp stage2_stop
	
	
%include 'stage2/a20.s'
%include 'stage2/mem.s'
%include 'stage2/unreal.s'
%include 'stage2/jgfs.s'
	
	
%define BOOT_CODE_PRINT_CHR
%define BOOT_CODE_PRINT_STR
%define BOOT_CODE_PRINT_HEX
%define BOOT_CODE_LBA_TO_CHS
%include 'common/boot.s'
%include 'common/string.s'
	
	
stage2_data:
.msg_hello:
	db `JGSYS STAGE2\r\n`
.msg_err_a20:
	db `A20 gate could not be enabled!\r\n`
.msg_err_mem:
	db `Could not get system memory map!\r\n`
.msg_err_jgfs_root_dc:
	db `Could not load the root dir cluster!\r\n`
.msg_err_jgfs_kern_lookup:
	db `Could not find the kernel!\r\n`
.msg_err_jgfs_kern_type:
	db `The kernel is not a file!\r\n`
.msg_err_jgfs_kern_load:
	db `Could not load the kernel:\r\n`
.msg_jgfs_err_int13:
	db `Read error!\r\n`
.msg_jgfs_err_bounds_sect:
	db `Sector bounds check failed!\r\n`
.msg_jgfs_err_bounds_fat:
	db `FAT bounds check failed!\r\n`
.msg_jgfs_err_fat_chain:
	db `Bad FAT chain!\r\n`
.msg_jgfs_err_unknown:
	db `Unknown JGFS error!\r\n`
.kern_filename:
	db `kern\0`
.boot_disk:
	db 0x00
.boot_part_entry:
	dw 0x0000
.param_sect:
	db 0x00
.param_head:
	db 0x00
	
stage2_fill:
	fill_to STAGE2_SIZE,0x00