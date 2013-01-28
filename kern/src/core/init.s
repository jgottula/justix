%define JGSYS_KERN_CORE_INIT
%include 'common/header.inc'
%include 'core/gdt.inc'
%include 'core/idt.inc'
	
	section .text
	
	global kern_entry:function
kern_entry:
	movzx esp,sp
	
	call gdt_setup
	
	jmp long 0x10:.long_jump
.long_jump:
	mov ax,0x08
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	
	mov esp,kern_stack_bottom
	
	call idt_setup
	
	int 0x0d
	int 0x0d
	
	;sti
	
	; for now, we'll just use unreal mode to say hi:
	mov word [0xb9000],0x7000|'H'
	mov word [0xb9002],0x7000|'i'
	
kern_stop:
	cli
	hlt
	jmp kern_stop
	
	
	section .bss
	
	global kern_stack_top:data
	global kern_stack_bottom:data
kern_stack_top:
	resb 0x1000
kern_stack_bottom:
