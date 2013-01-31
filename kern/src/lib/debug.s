%include 'common/header.inc'
	
	section .text
	
	; ax new cursor
video_set_cur:
	mov byte [0x3d4],0x0e
	mov byte [0x3d5],ah
	
	mov byte [0x3d4],0x0f
	mov byte [0x3d5],al
	
	ret
	
	; ax new cursor
video_set_page:
	mov byte [0x3d4],0x0e
	mov byte [0x3d5],ah
	
	mov byte [0x3d4],0x0f
	mov byte [0x3d5],al
	
	ret
	
	
	global debug_clear_screen:function
	; void debug_clear_screen(void)
debug_clear_screen:
	frame
	
	push edi
	
	mov eax,0x00000000
	mov edi,0x000b9000
	mov ecx,0x00001000
	
	rep stosd
	
	pop edi
	
	mov byte [0x3d4],0x0e
	mov byte [0x3d5],0x00
	
	mov byte [0x3d4],0x0f
	mov byte [0x3d5],0x00
	
	unframe
	ret
	
	
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
	
	mov eax,[ebp+4] ; ebp
	mov ecx,[ebp+8] ; stack_bottom
	
.trace_loop:
	cmp eax,ecx
	jae .done
	
	
	
.done:
	
	;push ebp
	;mov ebp,esp
	
	unframe
	ret
