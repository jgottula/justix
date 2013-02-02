%include 'common/header.inc'
%include 'core/exception.inc'
%include 'core/init.inc'
%include 'lib/debug.inc'
	
	section .text
	
	; TODO: add double fault handler
	; and register in idt
	; TODO: macro for trap/trap_end
	
trap_code trap_gpf
	
	invoke debug_write_fmt,str_gpf,eax,[ebp+4],[ebp+12],[ebp+8],[ebp+16]
	invoke debug_stack_trace,[ebp]
	
	mov word [0xb90a0],0x7000|'G'
	mov word [0xb90a2],0x7000|'P'
	mov word [0xb90a4],0x7000|'F'
	
	; TODO: do something useful with the problematic task instead of dying
	call kern_die
	
trap_end
	
	
	section .rodata
	
str_gpf:
	strz `GPF [%xd] @ %xw:%xd (eflags = %xd)\n`
