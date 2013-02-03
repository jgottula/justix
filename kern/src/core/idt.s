%include 'common/header.inc'
%include 'core/idt.inc'
%include 'core/gdt.inc'
%include 'core/trap.inc'
	
	section .text
	
func idt_setup
	invoke idt_setup_trap,0x06,trap_ud,0b10001111
	invoke idt_setup_trap,0x08,trap_df,0b10001111
	invoke idt_setup_trap,0x0d,trap_gp,0b10001111
	
	invoke idt_setup_trap,0x80,trap_syscall,0b11101111
	
	lidt [idt_table.info]
	
func_end
	
	
func_priv idt_setup_trap
	params index,addr,flag
	
	mov eax,[%$index]
	mov ecx,[%$addr]
	mov edx,[%$flag]
	
	mov [idt_table+eax*8],cx
	mov word [idt_table+eax*8+2],SEL_KERN_CODE
	mov byte [idt_table+eax*8+4],0x00
	mov [idt_table+eax*8+5],dl
	shr ecx,16
	mov [idt_table+eax*8+6],cx
	
func_end
	
	
	section .data
	
	global idt_table:data
idt_table:
	times 0x100 dq 0
.info:
	dw ((.info-idt_table)-1)
	dd idt_table
