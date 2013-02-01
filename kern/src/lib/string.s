%include 'common/header.inc'
%include 'lib/string.inc'
	
	section .text
	
func strlen
	params s
	locals foo
	save edi
	
	mov edi,[s]
	
	xor eax,eax
	mov ecx,eax
	not ecx
	
	cld
	repne scasb
	
	not ecx
	dec ecx
	
	mov eax,ecx
	
func_end
	
	
func strcmp
	params s1,s2
	
	; TODO
	
func_end
	
	
func memcmp
	params m1,m2,size
	save esi,edi
	
	mov esi,[ebp+4]
	mov edi,[ebp+8]
	mov ecx,[ebp+12]
	
	cld
	repne cmpsb
	
	mov eax,[esi]
	sub eax,[edi]
	
func_end
