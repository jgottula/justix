%include 'common/header.inc'
%include 'core/exception.inc'
%include 'core/main.inc'
%include 'lib/debug.inc'
	
	section .text
	
trap trap_ud
	
	invoke debug_write_fmt,str_ud,[%$cs],[%$eip],[%$eflags]
	invoke debug_stack_trace,[ebp]
	
	; TODO: do something useful with the problematic task instead of dying
	call kern_die
	
trap_end
	
	
trap_code trap_df
	
	invoke debug_write_fmt,str_df,[%$code],[%$cs],[%$eip],[%$eflags]
	invoke debug_stack_trace,[ebp]
	
	; fatal
	call kern_die
	
trap_end
	
	
trap_code trap_gp
	
	invoke debug_write_fmt,str_gp,[%$code],[%$cs],[%$eip],[%$eflags]
	invoke debug_stack_trace,[ebp]
	
	; TODO: do something useful with the problematic task instead of dying
	call kern_die
	
trap_end
	
	
	section .rodata
	
str_ud:
	strz `INVALID OPCODE @ %xw:%xd (eflags = %xd)\n`
str_gp:
	strz `GP FAULT [%xd] @ %xw:%xd (eflags = %xd)\n`
str_df:
	strz `DOUBLE FAULT [%xd] @ %xw:%xd (eflags = %xd)\n`
