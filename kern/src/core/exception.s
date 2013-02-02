%include 'common/header.inc'
%include 'core/exception.inc'
%include 'core/main.inc'
%include 'lib/debug.inc'
	
%macro auto_trap 1
trap trap_%1
	
	invoke trap_common,0,[%$cs],[%$eip],[%$eflags],str_%1
	
trap_end
%endm
	
%macro auto_trap_code 1
trap_code trap_%1
	
	invoke trap_common,[%$code],[%$cs],[%$eip],[%$eflags],str_%1
	
trap_end
%endm
	
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
	
	
auto_trap      ud
auto_trap_code df
auto_trap_code gp
	
	
	section .rodata
	
str_fmt:
	strz `%s [%xd] @ %xw:%xd (eflags = %xd)\n`
str_ud:
	strz `INVALID OPCODE`
str_gp:
	strz `GP FAULT`
str_df:
	strz `DOUBLE FAULT`
