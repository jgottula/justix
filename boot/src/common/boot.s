%ifdef BOOT_CODE_VIDEO_SETUP
boot_video_setup:
	push ax
	
	mov al,0x01
	
	mov ah,BIOS_VID_PAGE
	int 0x10
	
	pop ax
	ret
%endif

%ifdef BOOT_CODE_PRINT_CHR
	; AL ascii char
boot_print_chr:
	push ax
	push bx
	
	mov bh,0x01
	mov bl,COLOR(LTGRAY, BLACK)
	
	mov ah,BIOS_VID_TELETYPE
	int 0x10
	
	pop bx
	pop ax
	ret
%endif
	
	
%ifdef BOOT_CODE_PRINT_STR
	; CX    length
	; ES:BP string
boot_print_str:
	pusha
	
	mov bh,0x01
	
	push cx
	mov ah,BIOS_VID_GETCUR
	int 0x10
	pop cx
	
	mov al,0x01
	mov bh,0x01
	mov bl,COLOR(LTGRAY, BLACK)
	
	mov ah,BIOS_VID_STR
	int 0x10
	
	popa
	ret
%endif
	
	
%ifdef BOOT_CODE_PRINT_HEX
	; EAX dword
boot_print_dword:
	push eax
	
	shr eax,16
	call boot_print_word
	
	pop eax
	call boot_print_word
	
	ret
	
	
	; AX word
boot_print_word:
	push ax
	
	mov al,ah
	call boot_print_byte
	
	pop ax
	call boot_print_byte
	
	ret
	
	
	; AL byte
boot_print_byte:
	push ax
	
	shr ax,4
	call boot_print_nibble
	
	pop ax
	call boot_print_nibble
	
	ret
	
	
	; AL nibble
boot_print_nibble:
	push ax
	
	and al,0x0f
	
	cmp al,9
	jbe .numeric
	
	add al,'a'-'0'-0xa
	
.numeric:
	add al,'0'
	
	call boot_print_chr
	
	pop ax
	ret
%endif
	
	
%ifdef BOOT_CODE_LBA_TO_CHS
	; in:
	; EAX lba
	; CL  sectors/track
	; DH  heads/cylinder
	; out:
	; CX  cyl:sector
	; DH  head
boot_lba_to_chs:
	push bx
	push dx
	
	movzx bx,dh
	
	xor edx,edx
	movzx ecx,cl
	div ecx
	
	mov cl,dl
	inc cl
	; cl is now the sector number
	
	mov dx,0
	div bx
	; dx is now the head number
	; ax is now the cylinder number
	
	; head
	mov dh,dl
	
	; cylinder
	mov ch,al
	shr ax,2
	and al,0xc0
	or cl,al
	
	pop bx
	mov dl,bl
	
	pop bx
	ret
%endif
