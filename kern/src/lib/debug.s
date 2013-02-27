; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.

%include 'common/header.inc'
%include 'lib/debug.inc'
	
	section .text
	
func debug_stack_trace
	params base_ptr
	save esi
	
	invoke debug_write_str,str_stack_trace_header
	
	xor ebx,ebx
	mov esi,[%$base_ptr]
	
.trace_loop:
	or esi,esi
	jz .exit
	
	; get the return value
	invoke debug_write_fmt,str_stack_trace_line_fmt,ebx,[esi+4]
	
	; follow the chain
	mov esi,[esi]
	
	inc ebx
	
	jmp .trace_loop
	
func_end
	
	
	section .rodata
	
str_stack_trace_header:
	strz `stack trace:\n`
str_stack_trace_line_fmt:
	strz `[%i] 0x%xd\n`
