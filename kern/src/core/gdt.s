%include 'common/header.inc'
%include 'core/gdt.inc'
	
	section .text
	
	global gdt_setup:function
gdt_setup:
	; use extra segment since we are still in unreal mode
	lgdt [es:gdt_table.info]
	
	ret
	
	
	section .data
	
	global gdt_table:data
gdt_table:
.null:
	dd 0x00000000
	dd 0x00000000
.kern_data:
	dw 0xffff
	dw 0x0000
	db 0x00
	db GDT_ACC_PR | 0x10 | GDT_ACC_RW
	db 0x0f | GDT_FL_GR | GDT_FL_SZ
	db 0x00
.kern_code:
	dw 0xffff
	dw 0x0000
	db 0x00
	db GDT_ACC_PR | 0x10 | GDT_ACC_EX | GDT_ACC_RW
	db 0x0f | GDT_FL_GR | GDT_FL_SZ
	db 0x00
.user_data:
	dw 0xffff
	dw 0x0000
	db 0x00
	db GDT_ACC_PR | 0x70 | GDT_ACC_RW
	db 0x0f | GDT_FL_GR | GDT_FL_SZ
	db 0x00
.user_code:
	dw 0xffff
	dw 0x0000
	db 0x00
	db GDT_ACC_PR | 0x70 | GDT_ACC_EX | GDT_ACC_RW
	db 0x0f | GDT_FL_GR | GDT_FL_SZ
	db 0x00
.tss:
	dq 0
.info:
	dw ((.info-gdt_table)-1)
	dd gdt_table
