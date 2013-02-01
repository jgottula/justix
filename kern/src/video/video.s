%include 'common/header.inc'
%include 'video/video.inc'
	
	section .text
	
func video_set_cur
params cur
	
	mov ax,[cur]
	
	mov byte [0x3d4],0x0e
	mov byte [0x3d5],ah
	
	mov byte [0x3d4],0x0f
	mov byte [0x3d5],al
	
func_end
	
func video_clear_screen
	save edi
	
	mov eax,0x00000000
	mov edi,0x000b9000
	mov ecx,0x00001000
	
	rep stosd
	
	mov byte [0x3d4],0x0e
	mov byte [0x3d5],0x00
	
	mov byte [0x3d4],0x0f
	mov byte [0x3d5],0x00
	
func_end
