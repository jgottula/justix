	; in:
	; EAX sector
	; EDI buffer
	; out:
	; CF set on error
boot_jgfs_read_sector:
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
	movzx ecx,word [JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_PER_C]
	mul ecx
	
	; add reserved/fat sectors as offset
	mov dx,[JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_RSVD]
	add dx,[JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_FAT]
	movzx edx,dx
	
	add eax,edx
	
.read_loop:
	call boot_jgfs_read_sector
	jc .done
	
	inc eax
	add edi,0x200
	
	loop .read_loop
	
	clc
	
.done:
	popad
	ret
	
	
	; CF set on error
boot_jgfs_fat_load:
	pushad
	
	mov cx,[JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_FAT]
	movzx eax,word [JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_RSVD]
	mov edi,JGFS_FAT_OFFSET
	
.read_loop:
	call boot_jgfs_read_sector
	jc .done
	
	inc eax
	add edi,0x200
	
	loop .read_loop
	
	clc
	
.done:
	popad
	ret
	
	
	; in:
	; EAX addr
	; out:
	; AX value
boot_jgfs_fat_read:
	mov ax,[eax*2+JGFS_FAT_OFFSET]
	
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
	movzx eax,word [JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_PER_C]
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
boot_jgfs_read_file:
	pushad
	
	movzx ecx,word [JGFS_HDR_OFFSET+JGFS_HDR_OFF_S_PER_C]
	shl cx,9
	
	movzx eax,word [esi+JGFS_DE_OFF_BEGIN]
	
.read_loop:
	call boot_jgfs_read_clust
	jc .done
	
	add edi,ecx
	
	call boot_jgfs_fat_read
	
	cmp ax,JGFS_FAT_EOF
	jne .read_loop
	
	clc
	
.done:
	popad
	ret
