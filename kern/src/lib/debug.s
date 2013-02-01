%include 'common/header.inc'
%include 'lib/debug.inc'
	
	section .text
	
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
