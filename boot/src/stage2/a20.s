; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.


	; CF clear if A20 enabled
stage2_test_a20:
	cli
	pusha
	push ds
	push es
	
	xor ax,ax
	mov ds,ax
	
	not ax
	mov es,ax
	
	mov si,0x7dfe
	mov di,0x7e0e
	
	mov word [ds:si],0x0000
	mov word [es:di],0xffff
	
	mov ax,[ds:si]
	mov bx,[es:di]
	
	cmp ax,bx
	je .a20_fail
	
.a20_ok:
	clc
	jmp .done
	
.a20_fail:
	stc
	
.done:
	mov word [0x7dfe],BIOS_BOOT_FLAG
	
	pop ds
	pop es
	popa
	sti
	ret
	
	
stage2_enable_a20_bios:
	mov ax,BIOS_SYS_A20_ENABLE
	int 0x15
	
	ret
	
	
stage2_enable_a20_fast:
	in al,0x92
	or al,0x02
	out 0x92,al
	
	ret
	
	
stage2_enable_a20_8042:
	; not implemented
	ret
