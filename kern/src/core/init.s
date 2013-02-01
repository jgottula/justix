%include 'common/header.inc'
%include 'core/init.inc'
%include 'core/gdt.inc'
%include 'core/idt.inc'
%include 'lib/debug.inc'
%include 'lib/string.inc'
%include 'serial/serial.inc'
%include 'video/video.inc'
	
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
	
	; copy the memory map into kernel memory
	invoke memcpy,kern_mem_map,MEM_MAP_OFFSET,0x1000
	
	invoke serial_detect
	invoke serial_init,0,SER_38400,SER_8N1
	
	invoke serial_send_str,0,kern_hello
	
	; this stuff all needs to GO
	invoke video_clear_screen
	mov word [0xb9000],0x7000|'J'
	mov word [0xb9002],0x7000|'G'
	mov word [0xb9004],0x7000|'S'
	mov word [0xb9006],0x7000|'Y'
	mov word [0xb9008],0x7000|'S'
	mov word [0xb900a],0x7000|' '
	mov word [0xb900c],0x7000|'k'
	mov word [0xb900e],0x7000|'e'
	mov word [0xb9010],0x7000|'r'
	mov word [0xb9012],0x7000|'n'
	
	call a
a:	frame
	call b
b:	frame
	call c
c:	frame
	call d
d:	frame
	invoke debug_stack_trace,ebp
	
	jmp $
	
	
	section .rodata
	
kern_hello:
	strz `JGSYS kern\n`
	
	
	section .bss
	
gdata kern_stack_top
	resb 0x1000
gdata kern_stack_bottom
	
gdata kern_mem_map
	resb 0x1000
