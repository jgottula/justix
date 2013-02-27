; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.

	; in:
	; EDI string
	; out:
	; ECX length (excluding terminating NULL)
strlen:
	push ax
	push edi
	
	xor ecx,ecx
	not ecx
	
	xor ax,ax
	
	cld
	a32 repne es scasb
	
	not ecx
	dec ecx
	
	pop edi
	pop ax
	ret
	
	
	; in:
	; ESI buffer
	; EDI buffer
	; ECX  length
	; out:
	; ZF set on equality
memcmp:
	push esi
	push edi
	
	cld
	a32 repe es cmpsb
	
	pop edi
	pop esi
	ret
