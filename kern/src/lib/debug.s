%include 'common/header.inc'
%include 'lib/debug.inc'
	
	section .text
	
	
	global debug_print_char:function
	; void debug_print_char(char chr)
debug_print_char:
	frame
	
	
	
	unframe
	ret
	
	
	global debug_print_string:function
	; void debug_print_string(const char *str)
debug_print_string:
	frame
	
	
	
	unframe
	ret
	
	
	global debug_print_hex8:function
	; void debug_print_hex8(uint8_t hex)
debug_print_hex8:
	frame
	
	
	
	unframe
	ret
	
	
	global debug_print_hex16:function
	; void debug_print_hex16(uint16_t hex)
debug_print_hex16:
	frame
	
	
	
	unframe
	ret
	
	
	global debug_print_hex32:function
	; void debug_print_hex32(uint32_t hex)
debug_print_hex32:
	frame
	
	
	
	unframe
	ret
	
	
	global debug_stack_trace:function
	; void debug_stack_trace(void *ebp, void *stack_bottom)
debug_stack_trace:
	frame
	
	mov eax,param(0) ; ebp
	mov ecx,param(1) ; stack_bottom
	
.trace_loop:
	cmp eax,ecx
	jae .done
	
	
	
.done:
	
	
	unframe
	ret
