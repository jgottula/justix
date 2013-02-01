%include 'common/header.inc'
%include 'lib/string.inc'
	
	section .text
	
func strlen
	params s
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
	
	
func strcmp
	params s1,s2
	
	; TODO
	
func_end
	
	
func memcmp
	params m1,m2,size
	save esi,edi
	
	mov esi,[%$m1]
	mov edi,[%$m2]
	mov ecx,[%$size]
	
	cld
	repne cmpsb
	
	mov eax,[esi]
	sub eax,[edi]
	
func_end
	
	
func memset
	params mem,val,size
	save edi
	
	mov eax,[%$val]
	mov ecx,[%$size]
	mov edi,[%$mem]
	
	rep stosb
	
func_end
	
	
func memcpy
	params dst,src,size
	save esi,edi
	
	mov edi,[%$dst]
	mov esi,[%$src]
	mov ecx,[%$size]
	
	cld
	rep movsb
	
func_end
