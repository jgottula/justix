%include 'common/header.inc'
%include 'core/exception.inc'
%include 'core/main.inc'
%include 'lib/debug.inc'
	
	section .text
	
func trap_common
	params code,cs,eip,eflags,desc
	
	invoke debug_write_fmt,str_fmt,[%$desc],[%$code],[%$cs],[%$eip],[%$eflags]
	
	mov eax,[ebp]
	invoke debug_stack_trace,[eax]
	
	; for now, everything is fatal
	; TODO: salvage cases that aren't fatal
	call kern_die
	
func_end
	
trap trap_ud
	
	invoke trap_common,0,[%$cs],[%$eip],[%$eflags],str_ud
	
trap_end
	
	
trap_code trap_df
	
	invoke trap_common,[%$code],[%$cs],[%$eip],[%$eflags],str_df
	
trap_end
	
	
trap_code trap_gp
	
	invoke trap_common,[%$code],[%$cs],[%$eip],[%$eflags],str_gp
	
trap_end
	
	
	section .rodata
	
str_fmt:
	strz `%s [%xd] @ %xw:%xd (eflags = %xd)\n`
str_ud:
	strz `INVALID OPCODE`
str_gp:
	strz `GP FAULT`
str_df:
	strz `DOUBLE FAULT`
