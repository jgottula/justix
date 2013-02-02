	; in:
	; EAX sector
	; EDI buffer
	; out:
	; CF set on error
	; AL set on error
stage2_jgfs_read_sect:
	pushad
	
	; bounds check
	cmp eax,[es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_TOTAL]
	jae .fail_bounds
	
	mov si,[stage2_data.boot_part_entry]
	add eax,[si+MBR_PART_OFF_LBA]
	
	mov dh,[stage2_data.param_head]
	mov cl,[stage2_data.param_sect]
	
	call boot_lba_to_chs
	
	mov dl,[stage2_data.boot_disk]
	mov bx,JGFS_SECT_OFFSET
	mov al,0x01
	
	mov ah,BIOS_DISK_READ
	int 0x13
	
	jc .fail_int13
	
	mov ecx,0x80
	mov esi,JGFS_SECT_OFFSET
	
	cld
	a32 rep movsd
	
.ok:
	popad
	
	clc
	ret
	
.fail_bounds:
	popad
	mov al,JGFS_ERR_BOUNDS_SECT
	
	jmp .fail
	
.fail_int13:
	popad
	mov al,JGFS_ERR_INT13
	
.fail:
	stc
	ret
	
	
	; in:
	; EAX cluster
	; EDI buffer
	; out:
	; CF set on error
	; AL set on error
stage2_jgfs_read_clust:
	pushad
	
	; multiply by sect per clust
	movzx ecx,word [es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_PER_C]
	mul ecx
	
	; add vbr/hdr/boot/fat sectors as offset
	mov dx,JGFS_BOOT_SECT
	add dx,[es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_BOOT]
	add dx,[es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_FAT]
	movzx edx,dx
	
	add eax,edx
	
.read_loop:
	call stage2_jgfs_read_sect
	jc .fail
	
	inc eax
	add edi,0x200
	
	loop .read_loop
	
.ok:
	popad
	
	clc
	ret
	
.fail:
	; preserve error code
	mov [.temp],al
	popad
	mov al,[.temp]
	
	stc
	ret
	
.temp:
	db 0x00
	
	
stage2_jgfs_fat_init:
	pushad
	
	mov ecx,JGFS_MAX_FAT_SECT
	xor eax,eax
	mov edi,JGFS_FAT_BMP_OFFSET
	
	; zero out the fat sector bitmap
	cld
	a32 rep es stosb
	
	popad
	ret
	
	
	; in:
	; EAX addr
	; out:
	; AX value
	; CF set on failure to dynamically load fat
stage2_jgfs_fat_read:
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
	
	; bounds check
	cmp ax,[es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_FAT]
	jae .fail_bounds
	
	add ax,JGFS_BOOT_SECT
	add ax,[es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_BOOT]
	
	call stage2_jgfs_read_sect
	
	jnc .read_ok
	
.fail_read:
	; preserve error code
	mov [.temp],al
	
	popad
	pop esi
	
	mov al,[.temp]
	
	jmp .fail
	
.fail_bounds:
	popad
	pop esi
	
	mov al,JGFS_ERR_BOUNDS_FAT
	
.fail:
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
	
.temp:
	db 0x00
	
	
	; in:
	; EBP name
	; out:
	; EBP child (dir ent in parent)
	; CF  set on failure to find child
stage2_jgfs_lookup_child:
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
	
	pop edi
	pop esi
	
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
stage2_jgfs_read_file:
	pushad
	
	movzx ecx,word [es:JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_PER_C]
	shl cx,9
	
	movzx eax,word [es:esi+JGFS_DE_OFF_BEGIN]
	
.read_loop:
	call stage2_jgfs_read_clust
	jc .fail_read_clust
	
	add edi,ecx
	
	call stage2_jgfs_fat_read
	jc .fail_fat_read
	
	cmp ax,JGFS_FAT_EOF
	je .fat_ok
	
	; FAT_FREE is bad
	or ax,ax
	jz .fail_fat_chain
	
	; > FAT_LAST is bad (unless FAT_EOF)
	cmp ax,JGFS_FAT_LAST
	ja .fail_fat_chain
	
.fat_ok:
	jne .read_loop
	
.done:
	clc
	
	popad
	ret
	
.fail_read_clust:
.fail_fat_read:
	; preserve error code
	mov [.temp],al
	popad
	mov al,[.temp]
	
	jmp .fail
	
.fail_fat_chain:
	popad
	mov al,JGFS_ERR_FAT_CHAIN
	
.fail:
	stc
	ret
	
.temp:
	db 0x00
