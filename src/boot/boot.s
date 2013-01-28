%include 'common/header.inc'
%include 'common/macro.inc'
%include 'common/boot.inc'
%include 'common/bios.inc'
%include 'common/8042.inc'
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
	jnc .success
	
	mov cx,27
	mov bp,boot_data.msg_a20_bios
	call boot_print_str
	
	call boot_enable_a20_bios
	call boot_test_a20
	jnc .success
	
	mov cx,27
	mov bp,boot_data.msg_a20_fast
	call boot_print_str
	
	call boot_enable_a20_fast
	call boot_test_a20
	jnc .success
	
	; not implemented: 8042 a20 enable
	
.fail:
	mov cx,32
	mov bp,boot_data.msg_err_a20
	call boot_print_str
	
	jmp boot_stop
	
.success:
	mov cx,18
	mov bp,boot_data.msg_a20_success
	call boot_print_str
	
boot_find_mem:
	mov edx,0x534d4150
	xor ebx,ebx
	mov ecx,20
	mov di,MEM_MAP_OFFSET
	
	mov eax,BIOS_SYS_MEM_MAP
	int 0x15
	
	jc .mem_fail
	
	cmp eax,0x534d4150
	je .mem_loop
	
.mem_fail:
	mov cx,34
	mov bp,boot_data.msg_err_mem
	call boot_print_str
	
	jmp boot_stop
	
.mem_loop:
	mov eax,[di]
	call boot_print_dword
	
	mov al,' '
	call boot_print_chr
	
	mov eax,[di+8]
	call boot_print_dword
	
	mov al,' '
	call boot_print_chr
	
	mov eax,[di+16]
	call boot_print_dword
	
	mov al,`\n`
	call boot_print_chr
	mov al,`\r`
	call boot_print_chr
	
	or ebx,ebx
	jz .mem_done
	
	add di,20
	mov ecx,20
	
	mov eax,BIOS_SYS_MEM_MAP
	int 0x15
	
	jmp .mem_loop
	
.mem_done:
	
	
	; after the loop, sort the map (?)
	
boot_stop:
	cli
	hlt
	jmp boot_stop
	
	
%include 'boot/a20.s'
	
	
%define BOOT_CODE_PRINT_CHR
%define BOOT_CODE_PRINT_STR
%define BOOT_CODE_PRINT_HEX
%define BOOT_CODE_LBA_TO_CHS
%include 'common/boot.s'
	
	
boot_data:
.msg_hello:
	db `JGSYS BOOT\r\n`
.msg_a20_bios:
	db `Trying BIOS A20 enable...\r\n`
.msg_a20_fast:
	db `Trying fast A20 enable...\r\n`
.msg_a20_success:
	db `A20 gate enabled\r\n`
.msg_err_a20:
	db `A20 gate could not be enabled!\r\n`
.msg_err_mem:
	db `Could not get system memory map!\r\n`
	
boot_fill:
	fill_to BOOT_SIZE,0x00
