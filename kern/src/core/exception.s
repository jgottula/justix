%include 'common/header.inc'
%include 'core/exception.inc'
%include 'core/main.inc'
%include 'lib/debug.inc'
	
	section .text
	
trap_code trap_df
	
	invoke debug_write_fmt,str_df,eax,[%$code],[%$cs],[%$eip],[%$eflags]
	invoke debug_stack_trace,[ebp]
	
	mov word [0xb90a0],0x7000|'D'
	mov word [0xb90a4],0x7000|'F'
	
	; fatal
	call kern_die
	
trap_end
	
	
trap_code trap_gp
	
	invoke debug_write_fmt,str_gp,eax,[%$code],[%$cs],[%$eip],[%$eflags]
	invoke debug_stack_trace,[ebp]
	
	mov word [0xb90a0],0x7000|'G'
	mov word [0xb90a2],0x7000|'P'
	
	; TODO: do something useful with the problematic task instead of dying
	call kern_die
	
trap_end
	
	
	section .rodata
	
str_gp:
	strz `GP FAULT [%xd] @ %xw:%xd (eflags = %xd)\n`
str_df:
	strz `DOUBLE FAULT [%xd] @ %xw:%xd (eflags = %xd)\n`
