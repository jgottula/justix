	; cx    length
	; es:bp string
boot_print_msg:
	mov bh,0x01
	
	push cx
	mov ah,BIOS_VID_GETCUR
	int BIOS_VID
	pop cx
	
	mov al,0x01
	mov bh,0x01
	mov bl,BIOS_COLOR(LTGRAY, BLACK)
	
	mov ah,BIOS_VID_STR
	int BIOS_VID
	
	ret
