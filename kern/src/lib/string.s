%include 'common/header.inc'
	
	section .text
	
	global strlen:function
strlen:
	frame
	
	push edi
	mov edi,[ebp+4]
	
	xor eax,eax
	mov ecx,eax
	not ecx
	
	cld
	repne scasb
	
	not ecx
	dec ecx
	
	mov eax,ecx
	
	pop edi
	
	unframe
	ret
	
	
	global strcmp:function
strcmp:
	
	
	ret
	
	
	global memcmp:function
memcmp:
	frame
	
	push esi
	push edi
	
	mov esi,[ebp+4]
	mov edi,[ebp+8]
	mov ecx,[ebp+12]
	
	cld
	repne cmpsb
	
	mov eax,[esi]
	sub eax,[edi]
	
	pop edi
	pop esi
	
	unframe
	ret
