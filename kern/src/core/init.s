%include 'common/header.inc'
%include 'core/init.inc'
%include 'core/gdt.inc'
%include 'core/idt.inc'
%include 'core/main.inc'
	
	section .text.init
	
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
	mov ebp,0x00000000
	
	call idt_setup
	
	sti
	
	call kern_main
	
	
	section .bss
	
gdata kern_stack_top
	resb 0x1000
gdata kern_stack_bottom
