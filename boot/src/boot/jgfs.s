	; in:
	; EAX sector
	; EDI buffer
	; out:
	; CF set on error
boot_jgfs_read_sect:
	pushad
	
	mov si,[boot_data.boot_part_entry]
	add eax,[si+MBR_PART_OFF_LBA]
	
	mov dh,[boot_data.param_head]
	mov cl,[boot_data.param_sect]
	
	call boot_lba_to_chs
	
	mov dl,[boot_data.boot_disk]
	mov bx,JGFS_SECT_OFFSET
	mov al,0x01
	
	mov ah,BIOS_DISK_READ
	int 0x13
	
	jc .done
	
	cld
	
	mov ecx,0x200
	mov esi,JGFS_SECT_OFFSET
	
	a32 rep movsd
	
	clc
	
.done:
	popad
	ret
	
	
	; in:
	; EAX cluster
	; EDI buffer
	; out:
	; CF set on error
boot_jgfs_read_clust:
	pushad
	
	; multiply by sect per clust
	movzx ecx,word [es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_PER_C]
	mul ecx
	
	; add reserved/fat sectors as offset
	mov dx,[es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_RSVD]
	add dx,[es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_FAT]
	movzx edx,dx
	
	add eax,edx
	
.read_loop:
	call boot_jgfs_read_sect
	jc .done
	
	inc eax
	add edi,0x200
	
	loop .read_loop
	
	clc
	
.done:
	popad
	ret
	
	
boot_jgfs_fat_init:
	pushad
	
	cld
	
	mov ecx,0x200
	xor eax,eax
	mov edi,JGFS_FAT_BMP_OFFSET
	
	; zero out the fat sector bitmap
	a32 rep es stosb
	
	popad
	ret
	
	
	; in:
	; EAX addr
	; out:
	; AX value
	; CF set on failure to dynamically load fat
boot_jgfs_fat_read:
	push esi
	push dx
	
	; here, we assume that JGFS_FENT_PER_SECT is 256
	movzx esi,ah
	mov dl,[es:esi+JGFS_FAT_BMP_OFFSET]
	or dl,dl
	
	pop dx
	
	jnz .fat_loaded
	
.load_fat:
	pushad
	
	xor al,al
	lea edi,[es:eax*2+JGFS_FAT_OFFSET]
	
	movzx eax,ah
	add ax,[es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_RSVD]
	
	call boot_jgfs_read_sect
	
	jnc .read_ok
	
.read_fail:
	popad
	pop esi
	
	stc
	ret
	
.read_ok:
	popad
	
	; set the bitmap now
	movzx esi,ah
	mov byte [es:esi+JGFS_FAT_BMP_OFFSET],0xff
	
.fat_loaded:
	pop esi
	
	mov ax,[es:eax*2+JGFS_FAT_OFFSET]
	
	clc
	ret
	
	
	; in:
	; EBP name
	; out:
	; EBP child (dir ent in parent)
	; CF  set on failure to find child
boot_jgfs_lookup_child:
	push eax
	push ecx
	push esi
	push edi
	
	mov esi,JGFS_CLUST_OFFSET
	
	; get strlen+1 in ecx
	mov edi,ebp
	call strlen
	inc ecx
	
	; get cluster size
	movzx eax,word [es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_PER_C]
	shl eax,9
	
	; end pointer
	mov edi,esi
	add edi,eax
	
	; skip to first dir ent
	add esi,JGFS_DC_OFF_FIRST_DE
	
.dir_ent_loop:
	push esi
	push edi
	
	add esi,JGFS_DE_OFF_NAME
	mov edi,ebp
	call memcmp
	
	pop esi
	pop edi
	
	je .found
	
	add esi,JGFS_DE_SIZE
	cmp esi,edi
	
	jae .dir_ent_loop
	
.not_found:
	stc
	
	jmp .done
	
.found:
	mov ebp,esi
	clc
	
.done:
	pop edi
	pop esi
	pop ecx
	pop eax
	ret
	
	; in:
	; ESI dir ent
	; EDI buffer
	; out:
	; CF set on failure
	; AL error on failure
boot_jgfs_read_file:
	pushad
	
	movzx ecx,word [es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_PER_C]
	shl cx,9
	
	movzx eax,word [es:esi+JGFS_DE_OFF_BEGIN]
	
.read_loop:
	call boot_jgfs_read_clust
	jc .fail_int13
	
	add edi,ecx
	
	call boot_jgfs_fat_read
	jc .fail_fat_load
	
	cmp ax,JGFS_FAT_EOF
	je .fat_ok
	
	; FAT_FREE is bad
	or ax,ax
	jz .fail_fat_chain
	
	; > FAT_LAST is bad (unless FAT_EOF)
	cmp ax,JGFS_FAT_LAST+1
	jae .fail_fat_chain
	
.fat_ok:
	jne .read_loop
	
.done:
	clc
	
	popad
	ret
	
.fail_int13:
	popad
	mov al,JGFS_ERR_INT13
	
	jmp .fail
	
.fail_fat_load:
	popad
	mov al,JGFS_ERR_FAT_LOAD
	
	jmp .fail
	
.fail_fat_chain:
	popad
	mov al,JGFS_ERR_FAT_CHAIN
	
.fail:
	stc
	ret
