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
	
	mov bp,stage2_data.msg_hello
	call boot_print_line
	
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
	mov bp,stage2_data.msg_err_a20
	call boot_print_line
	
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
	mov bp,stage2_data.msg_err_mem
	call boot_print_line
	
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
	mov bp,stage2_data.msg_err_jgfs_root_dc
	call boot_print_line
	
	jmp stage2_stop
	
.root_clust_ok:
	mov ebp,stage2_data.kern_filename
	call stage2_jgfs_lookup_child
	
	jnc .found_kern
	
.not_found:
	mov bp,stage2_data.msg_err_jgfs_kern_lookup
	call boot_print_line
	
	jmp stage2_stop
	
.found_kern:
	mov ax,[ebp+JGFS_DE_OFF_TYPE]
	cmp ax,JGFS_TYPE_FILE
	
	je .type_ok
	
.type_fail:
	mov bp,stage2_data.msg_err_jgfs_kern_type
	call boot_print_line
	
	jmp stage2_stop
	
.type_ok:
	mov esi,ebp
	mov edi,KERN_OFFSET
	
	call stage2_jgfs_read_file
	
	jnc stage2_enter_kernel
	
.load_fail:
	mov bp,stage2_data.msg_err_jgfs_kern_load
	call boot_print_line
	
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
	mov bp,stage2_data.msg_jgfs_err_int13
	jmp .load_fail_rejoin
	
.load_fail_bounds_sect:
	mov bp,stage2_data.msg_jgfs_err_bounds_sect
	jmp .load_fail_rejoin
	
.load_fail_bounds_fat:
	mov bp,stage2_data.msg_jgfs_err_bounds_fat
	jmp .load_fail_rejoin
	
.load_fail_fat_chain:
	mov bp,stage2_data.msg_jgfs_err_fat_chain
	jmp .load_fail_rejoin
	
.load_fail_unknown:
	mov bp,stage2_data.msg_jgfs_err_unknown
	
.load_fail_rejoin:
	call boot_print_line
	
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
%define BOOT_CODE_PRINT_LINE
%define BOOT_CODE_PRINT_HEX
%define BOOT_CODE_LBA_TO_CHS
%include 'common/boot.s'
%include 'common/string.s'
	
	
stage2_data:
.msg_hello:
	strz `JGSYS STAGE2`
.msg_err_a20:
	strz `A20 gate could not be enabled!`
.msg_err_mem:
	strz `Could not get system memory map!`
.msg_err_jgfs_root_dc:
	strz `Could not load the root dir cluster!`
.msg_err_jgfs_kern_lookup:
	strz `Could not find the kernel!`
.msg_err_jgfs_kern_type:
	strz `The kernel is not a file!`
.msg_err_jgfs_kern_load:
	strz `Could not load the kernel:`
.msg_jgfs_err_int13:
	strz `Read error!`
.msg_jgfs_err_bounds_sect:
	strz `Sector bounds check failed!`
.msg_jgfs_err_bounds_fat:
	strz `FAT bounds check failed!`
.msg_jgfs_err_fat_chain:
	strz `Bad FAT chain!`
.msg_jgfs_err_unknown:
	strz `Unknown JGFS error!`
.kern_filename:
	strz `kern`
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
