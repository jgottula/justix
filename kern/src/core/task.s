%include 'common/header.inc'
%include 'core/task.inc'
%include 'core/gdt.inc'
	
	section .text
	
func task_flush_tss
	
	mov ax,(SEL_TSS|0b11)
	ltr ax
	
func_end
