	; CF clear on success
boot_mem_e820:
	mov edx,0x534d4150
	xor ebx,ebx
	mov ecx,20
	mov di,MEM_MAP_OFFSET
	
	mov eax,BIOS_SYS_MEM_MAP
	int 0x15
	
	jc .fail
	
	cmp eax,0x534d4150
	jne .fail
	
.e820_loop:
	or ebx,ebx
	jz .done
	
	add di,20
	mov ecx,20
	
	mov eax,BIOS_SYS_MEM_MAP
	int 0x15
	
	jmp .e820_loop
	
.done:
	mov cx,20
	xor eax,eax
	rep stosd
	
	clc
	ret
	
.fail:
	stc
	ret
	
	; CF clear on success
boot_mem_int12:
	mov di,MEM_MAP_OFFSET
	
	int 0x12
	
	jc .fail
	
	; convert up from kilobytes
	movzx ebx,ax
	shl ebx,10
	
	; get the size of the remainder of 1M
	mov eax,(1*1024*1024)
	sub eax,ebx
	
	; entry for first 1M
	mov dword [di+00],0x00000000 ; addr low
	mov dword [di+04],0x00000000 ; addr high
	mov dword [di+08],ebx        ; size low
	mov dword [di+12],0x00000000 ; size high
	mov dword [di+16],BIOS_MEM_USABLE ; type
	
	; entry for the rest of the first 1M
	mov dword [di+20],ebx        ; addr low
	mov dword [di+24],0x00000000 ; addr high
	mov dword [di+28],eax        ; size low
	mov dword [di+32],0x00000000 ; size high
	mov dword [di+36],BIOS_MEM_RESERVED ; type
	
.done:
	mov cx,20
	xor eax,eax
	add di,40
	rep stosd
	
	clc
	ret
	
.fail:
	stc
	ret
	
	; CF clear on success
boot_mem_e881_e801:
	mov di,MEM_MAP_OFFSET+40
	
	mov ax,0xe881
	int 0x15
	
	jnc .e881_ok
	
.e881_fail:
	mov ax,0xe801
	int 0x15
	
	jc .fail
	
.e801_extend:
	movzx eax,ax
	movzx ebx,bx
	movzx ecx,cx
	movzx edx,dx
	
.e881_ok:
	or eax,eax
	jnz .axbx_ok
	
	; accomodate [e]cx/[e]dx instead of the usual [e]ax/[e]bx
	mov eax,ecx
	mov ebx,edx
	
.axbx_ok:
	cmp eax,0x00003c00
	je .no_hole
	
	; convert up from kilobytes
	mov ecx,eax
	shl ecx,10
	
	; get the size of the remainder of 1-16M
	mov edx,(15*1024*1024)
	sub edx,ecx
	
	; entry for above 1M
	mov dword [di+00],0x00100000 ; addr low
	mov dword [di+04],0x00000000 ; addr high
	mov dword [di+08],ecx        ; size low
	mov dword [di+12],0x00000000 ; size high
	mov dword [di+16],BIOS_MEM_USABLE ; type
	
	add ecx,(1*1024*1024)
	
	; entry for the rest of the first 16M
	mov dword [di+20],ecx        ; addr low
	mov dword [di+24],0x00000000 ; addr high
	mov dword [di+28],edx        ; size low
	mov dword [di+32],0x00000000 ; size high
	mov dword [di+36],BIOS_MEM_RESERVED ; type
	
	; convert up from 64K blocks
	shl ebx,16
	
	; entry for above 16M
	mov dword [di+40],0x01000000 ; addr low
	mov dword [di+44],0x00000000 ; addr high
	mov dword [di+48],ebx        ; size low
	mov dword [di+52],0x00000000 ; size high
	mov dword [di+56],BIOS_MEM_USABLE ; type
	
	add di,60
	jmp .done
	
.no_hole:
	; convert up from kilobytes
	shl eax,10
	
	; convert up from 64K blocks
	shl ebx,16
	
	add eax,ebx
	
	; entry for everything above 1M
	mov dword [di+00],0x00100000 ; addr low
	mov dword [di+04],0x00000000 ; addr high
	mov dword [di+08],eax        ; size low
	mov dword [di+12],0x00000000 ; size high
	mov dword [di+16],BIOS_MEM_USABLE ; type
	
	add di,20
	
.done:
	mov cx,20
	xor eax,eax
	rep stosd
	
	clc
	ret
	
.fail:
	stc
	ret
	
	; CF clear on success
boot_mem_88:
	
	
.done:
	;mov cx,20
	;xor eax,eax
	;rep stosd
	
	clc
	ret
	
.fail:
	stc
	ret
	
boot_mem_dump_map:
	push si
	push eax
	
	mov si,MEM_MAP_OFFSET
	
.dump_loop:
	; exit after an entry with type of zero
	mov eax,[si+16]
	or eax,eax
	jz .done
	
	mov eax,[si]
	call boot_print_dword
	
	mov al,' '
	call boot_print_chr
	
	mov eax,[si+8]
	call boot_print_dword
	
	mov al,' '
	call boot_print_chr
	
	mov eax,[si+16]
	call boot_print_dword
	
	mov al,`\n`
	call boot_print_chr
	mov al,`\r`
	call boot_print_chr
	
	add si,20
	jmp .dump_loop
	
.done:
	pop eax
	pop si
	ret
