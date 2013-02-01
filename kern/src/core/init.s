%include 'common/header.inc'
%include 'core/gdt.inc'
%include 'core/idt.inc'
%include 'lib/debug.inc'
	
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
	
	call idt_setup
	
	int 0x0d
	int 0x0d
	
	call debug_clear_screen
	
	invoke debug_stack_trace,0xaa,0xbb,0xcc
	
	;sti
	
	; serial?
;   outb(PORT + 1, 0x00);    // Disable all interrupts
;   outb(PORT + 3, 0x80);    // Enable DLAB (set baud rate divisor)
;   outb(PORT + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
;   outb(PORT + 1, 0x00);    //                  (hi byte)
;   outb(PORT + 3, 0x03);    // 8 bits, no parity, one stop bit
;   outb(PORT + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
;   outb(PORT + 4, 0x0B);    // IRQs enabled, RTS/DSR set
	mov dx,0x3f8+1
	mov ax,0x00
	out dx,ax
	mov dx,0x3f8+1
	mov ax,0x00
	out dx,ax
	mov dx,0x3f8+3
	mov ax,0x80
	out dx,ax
	mov dx,0x3f8+0
	mov ax,0x03
	out dx,ax
	mov dx,0x3f8+1
	mov ax,0x00
	out dx,ax
	mov dx,0x3f8+3
	mov ax,0x03
	out dx,ax
	mov dx,0x3f8+2
	mov ax,0xc7
	out dx,ax
	mov dx,0x3f8+4
	mov ax,0x0b
	out dx,ax
	
	mov al,'e'
	out 0xe9,al
	mov al,'9'
	out 0xe9,al
	
	mov dx,0x8a00
	mov ax,0x8a00
	out dx,ax
	mov ax,0x8ae0
	out dx,ax
	
	mov al,'H'
	call serial_write_char
	mov al,'i'
	call serial_write_char
	
	mov word [0xb9000],0x7000|'H'
	mov word [0xb9002],0x7000|'i'
	
	mov word [0x462],0x00
	
kern_stop:
	cli
	hlt
	jmp kern_stop
	
serial_write_char:
	push ax
	push dx
	
	mov dx,0x3f8+5
	
.wait:
	in al,dx
	test al,0x20
	jz .wait
	
	pop ax
	
	mov dx,0x3f8+0
	out dx,al
	
	pop dx
	
	ret
	
	
	section .bss
	
	global kern_stack_top:data
kern_stack_top:
	resb 0x1000
	global kern_stack_bottom:data
kern_stack_bottom:
