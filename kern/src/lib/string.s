%include 'common/header.inc'
	
	section .text
	
func strlen
	params s
	locals foo:dword
	save edi
	
	mov edi,[%$s]
	
	xor eax,eax
	mov ecx,eax
	not ecx
	
	cld
	repne scasb
	
	not ecx
	dec ecx
	
	mov eax,ecx
	
func_end
	
	
	global strcmp:function
strcmp:
	
	
	ret
	
	
	global memcmp:function
memcmp:
	;frame
	;save esi,edi
	
	mov esi,[ebp+4]
	mov edi,[ebp+8]
	mov ecx,[ebp+12]
	
	cld
	repne cmpsb
	
	mov eax,[esi]
	sub eax,[edi]
	
	;unsave esi,edi
	;unframe
	ret
