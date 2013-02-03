%include 'common/header.inc'
%include 'core/trap.inc'
%include 'core/main.inc'
%include 'lib/debug.inc'
	
%macro auto_trap 1
trap trap_%1
	
	lea eax,[%$regs]
	invoke trap_common,eax,0,[%$cs],[%$eip],[%$eflags],str_%1
	
trap_end
%endm
	
%macro auto_trap_code 1
trap_code trap_%1
	
	lea eax,[%$regs]
	invoke trap_common,eax,[%$code],[%$cs],[%$eip],[%$eflags],str_%1
	
trap_end
%endm
	
	section .text
	
func trap_common
	params regs,code,cs,eip,eflags,desc
	
	invoke debug_write_fmt,str_fmt,[%$desc],[%$code],[%$cs],[%$eip],[%$eflags]
	
	mov eax,[ebp]
	invoke debug_stack_trace,[eax]
	
	invoke debug_dump_saved_reg,[%$regs]
	invoke debug_dump_mem,[%$eip],16
	
	; for now, everything is fatal
	; TODO: salvage cases that aren't fatal
	call kern_die
	
func_end
	
	
auto_trap      ud
auto_trap_code df
auto_trap_code gp
	
	
trap trap_syscall
	
	
	
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
