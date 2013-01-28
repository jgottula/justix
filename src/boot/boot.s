%include 'common/header.inc'
%include 'common/macro.inc'
%include 'common/boot.inc'
%include 'common/bios.inc'
%include 'common/gdt.inc'
%include 'common/jgfs.inc'
	
	cpu 386
	bits 16
	
	org BOOT_OFFSET
	section .text align=1
	
	; from the vbr:
	; DL boot disk
	; SI partition entry
boot_begin:
	push dx
	push si
	
	mov cx,12
	mov bp,boot_data.msg_hello
	call boot_print_str
	
	; TODO:
	; - enable A20 gate
	; - query memory
	; - enter unreal mode
	; - load the kernel
	; - go to protected mode
	; - jump to the kernel
boot_enable_a20:
	call boot_test_a20
	jnc boot_find_mem
	
	call boot_enable_a20_bios
	call boot_test_a20
	jnc boot_find_mem
	
	call boot_enable_a20_fast
	call boot_test_a20
	jnc boot_find_mem
	
	; not implemented: 8042 a20 enable
	
.fail:
	mov cx,32
	mov bp,boot_data.msg_err_a20
	call boot_print_str
	
	jmp boot_stop
	
boot_find_mem:
	call boot_mem_e820
	jnc .mem_done
	
	call boot_mem_int12
	jc .mem_fail
	
	call boot_mem_e881_e801
	jnc .mem_done
	
	; not implemented: int 0x15 ah=0x88
	
.mem_fail:
	mov cx,34
	mov bp,boot_data.msg_err_mem
	call boot_print_str
	
	jmp boot_stop
	
.mem_done:
	call boot_mem_dump_map
	
boot_go_unreal:
	call boot_enter_unreal
	
	mov bx,0x0f01
	mov eax,0x000b9000
	mov [fs:eax],bx
	
boot_stop:
	cli
	hlt
	jmp boot_stop
	
	
%include 'boot/a20.s'
%include 'boot/mem.s'
%include 'boot/unreal.s'
	
	
%define BOOT_CODE_PRINT_CHR
%define BOOT_CODE_PRINT_STR
%define BOOT_CODE_PRINT_HEX
%define BOOT_CODE_LBA_TO_CHS
%include 'common/boot.s'
	
	
boot_data:
.msg_hello:
	db `JGSYS BOOT\r\n`
.msg_err_a20:
	db `A20 gate could not be enabled!\r\n`
.msg_err_mem:
	db `Could not get system memory map!\r\n`
	
boot_fill:
	fill_to BOOT_SIZE,0x00
