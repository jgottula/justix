	; out:
	; ES flat 32-bit segment
boot_enter_unreal:
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
	
	; set fs and gs to descriptor 1
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
.flat:
	dw 0xffff
	dw 0x0000
	db 0x00
	db GDT_ACC_PR | 0x10 | GDT_ACC_RW
	db 0x0f | GDT_FL_GR | GDT_FL_SZ
	db 0x00
.end:
.info:
	dw (.end-.null)-1
	dd unreal_gdt
