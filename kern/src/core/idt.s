%include 'common/header.inc'
%include 'core/idt.inc'
%include 'core/exception.inc'
	
	section .text
	
	global idt_setup:function
idt_setup:
	mov eax,0x0d
	mov ecx,trap_gpf
	call idt_setup_trap
	
	lidt [idt_table.info]
	
	ret
	
idt_setup_trap:
	mov word [idt_table+eax*8],cx
	mov word [idt_table+eax*8+2],0x10
	mov byte [idt_table+eax*8+4],0x00
	mov byte [idt_table+eax*8+5],0b10001111
	shr ecx,16
	mov word [idt_table+eax*8+6],cx
	
	ret
	
	
	section .data
	
	global idt_table:data
idt_table:
	times 0x100 dq 0
.info:
	dw ((.info-idt_table)-1)
	dd idt_table
