; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.


%include 'common/header.inc'
%include 'core/task.inc'
%include 'core/gdt.inc'
	
	section .text
	
func task_flush_tss
	
	mov ax,(SEL_TSS|0b11)
	ltr ax
	
func_end
	
	
	global task_enter_ring3:function
task_enter_ring3:
	; TODO: make sure frame/stack behavior is consistent
	frame
	
	; get eflags while interrupts are as they were
	pushf
	pop ecx
	
	cli
	
	mov ax,(SEL_USER_DATA|0b11)
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	
	; set IOPL to 3
	or ecx,0x3000
	
	push (SEL_USER_DATA|0b11)
	push user_stack_bottom
	push ecx
	push (SEL_USER_CODE|0b11)
	push dword [ebp+8]
	
	sti
	iret
	
	
	section .bss
	
gdata user_stack_top
	resb 0x1000
gdata user_stack_bottom
