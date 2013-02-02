%include 'common/header.inc'
%include 'core/init.inc'
%include 'core/gdt.inc'
%include 'core/idt.inc'
%include 'core/main.inc'
%include 'lib/string.inc'
	
	section .text.init
	
	global kern_entry:function
kern_entry:
	movzx esp,sp
	
	call gdt_setup
	
	jmp long SEL_KERN_CODE:.long_jump
.long_jump:
	mov ax,SEL_KERN_DATA
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	
	mov esp,kern_stack_bottom
	mov ebp,0x00000000
	
	; clear the BSS _before_ we use the stack (which is in the bss)
	xor eax,eax
	mov edi,_BSS_START
	mov ecx,_BSS_SIZE
	
	cld
	rep stosb
	
	call idt_setup
	
	;sti
	
	call kern_main
	
	
	section .bss
	
gdata kern_stack_top
	resb 0x1000
gdata kern_stack_bottom
