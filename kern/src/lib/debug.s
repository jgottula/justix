%include 'common/header.inc'
%include 'lib/debug.inc'
%include 'core/init.inc'
	
	section .text
	
func debug_stack_trace
	params base_ptr
	save esi
	
	invoke debug_write_str,str_stack_trace_header
	
	xor ebx,ebx
	mov esi,[%$base_ptr]
	
.trace_loop:
	or esi,esi
	jz .last
	
	; get the return value
	mov eax,[esi+4]
	invoke debug_write_fmt,str_stack_trace_line_fmt,ebx,eax
	
	; follow the chain
	mov esi,[esi]
	
	inc ebx
	
	jmp .trace_loop
	
.last:
	invoke debug_write_fmt,str_stack_trace_line_fmt,ebx,kern_entry
	
func_end
	
	
	section .rodata
	
str_stack_trace_header:
	strz `stack trace:\n`
str_stack_trace_line_fmt:
	strz `[%i] 0x%d\n`
