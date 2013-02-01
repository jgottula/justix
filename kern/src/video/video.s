%include 'common/header.inc'
%include 'lib/string.inc'
%include 'video/video.inc'
	
	section .text
	
	; NOTE: this stuff is all deprecated and should be replaced by the virtual
	;       8086 monitor and video bios (int 0x10) calls
	
func video_set_cur
	params cur
	
	mov ax,[%$cur]
	
	mov byte [0x3d4],0x0e
	mov byte [0x3d5],ah
	
	mov byte [0x3d4],0x0f
	mov byte [0x3d5],al
	
func_end
	
	
func video_clear_screen
	
	invoke memset,0xb9000,0x00,0x1000
	invoke video_set_cur,0x0000
	
func_end
