; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.


%include 'common/header.inc'
%include 'core/intr.inc'
%include 'core/main.inc'
%include 'platform/pic.inc'
%include 'lib/debug.inc'
%include 'serial/serial.inc'
	
	section .text
	
%assign irq 0
%rep 0x10
%if irq != 3 && irq != 4
trap intr_irq%+irq
	
	invoke debug_write_fmt,str_irq,irq
	
	invoke pic_eoi,irq
	
trap_end
%endif
%assign irq irq+1
%endrep
	
	
trap intr_bad
	
	; TODO: query the PIC for info on which interrupt this is (if possible?)
	
	invoke debug_write_fmt,str_badint,[%$cs],[%$eip],[%$eflags]
	invoke debug_stack_trace,[ebp]
	
	lea eax,[%$regs]
	invoke debug_dump_saved_reg,eax
	
	; for now, everything is fatal
	; TODO: salvage cases that aren't fatal
	call kern_die
	
trap_end
	
	
trap intr_irq3
	
	invoke serial_intr
	invoke pic_eoi,3
	
trap_end
	
	
trap intr_irq4
	
	invoke serial_intr
	invoke pic_eoi,4
	
trap_end
	
	
	section .rodata
	
str_irq:
	strz `IRQ %xb\n`
str_badint:
	strz `BAD INT @ %xw:%xd (eflags = %xd)\n`
