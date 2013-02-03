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
	
	
auto_trap      de
auto_trap      db
auto_trap      bp
auto_trap      of
auto_trap      br
auto_trap      ud
auto_trap      nm
auto_trap      df ; no error code??
auto_trap_code ts
auto_trap_code np
auto_trap_code ss
auto_trap_code gp
auto_trap_code pf
auto_trap      mf
auto_trap_code ac
auto_trap      mc
auto_trap      xm
auto_trap      sx
	
	
trap trap_syscall
	
	; set IOPL to 0
	pushf
	pop eax
	or eax,0x3000
	push eax
	popf
	
	invoke debug_write_fmt,str_syscall,[%$cs],[%$eip],[%$eflags]
	
	mov eax,[ebp]
	invoke debug_stack_trace,[eax]
	invoke debug_dump_saved_reg,[%$regs]
	
trap_end
	
	
	section .rodata
	
str_fmt:
	strz `%s [%xd] @ %xw:%xd (eflags = %xd)\n`
str_de:
	strz `DIVIDE ERROR`
str_db:
	strz `DEBUG TRAP`
str_bp:
	strz `BREAKPOINT`
str_of:
	strz `OVERFLOW`
str_br:
	strz `BOUND RANGE EXCEEDED`
str_ud:
	strz `INVALID OPCODE`
str_nm:
	strz `DEVICE NOT AVAILABLE`
str_df:
	strz `DOUBLE FAULT`
str_ts:
	strz `INVALID TSS`
str_np:
	strz `SEGMENT NOT PRESENT`
str_ss:
	strz `STACK FAULT`
str_gp:
	strz `GP FAULT`
str_pf:
	strz `PAGE FAULT`
str_mf:
	strz `FPU ERROR`
str_ac:
	strz `ALIGNMENT CHECK`
str_mc:
	strz `MACHINE CHECK`
str_xm:
	strz `SIMD ERROR`
str_sx:
	strz `SECURITY EXCEPTION`
str_syscall:
	strz `SYSCALL @ %xw:%xd (eflags = %xd)\n`
