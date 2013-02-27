; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.

	; out:
	; ES flat 32-bit segment
stage2_enter_unreal:
	cli
	
	xor ax,ax
	mov fs,ax
	mov gs,ax
	
	push es
	
	lgdt [unreal_gdt.info]
	
	; enter protected mode
	mov eax,cr0
	or al,0x01
	mov cr0,eax
	
	; set es to descriptor 1
	mov bx,0x08
	mov es,bx
	
	; leave protected mode
	and al,~0x01
	mov cr0,eax
	
	pop es
	
	sti
	ret
	
	
unreal_gdt:
.null:
	dd 0x00000000
	dd 0x00000000
.data:
	dw 0xffff
	dw 0x0000
	db 0x00
	db GDT_ACC_PR | 0x10 | GDT_ACC_RW
	db 0x0f | GDT_FL_GR | GDT_FL_SZ
	db 0x00
.code:
	dw 0xffff
	dw (KERN_OFFSET & 0xffff)
	db (KERN_OFFSET >> 16) & 0xff
	db GDT_ACC_PR | 0x10 | GDT_ACC_EX | GDT_ACC_RW
	db 0x0f | GDT_FL_GR | GDT_FL_SZ
	db (KERN_OFFSET >> 24) & 0xff
.end:
.info:
	dw (.end-unreal_gdt)-1
	dd unreal_gdt
