%include 'common/header.inc'
%include 'serial/serial.inc'
	
	section .text
	
func serial_detect
	
	xor eax,eax
	mov ecx,eax
	
.dev_loop:
	; read the IRQ from the BIOS data area
	mov dx,[0x400+ecx*2]
	test dx,0xffff
	jz .nope
	
	mov [serial_irq+ecx*2],dx
	
	shl eax,1
	or eax,0b1
	
.nope:
	inc ecx
	cmp ecx,4
	jb .dev_loop
	
func_end
	
	
func serial_init
	params dev,divisor,config
	save ebx
	
	mov ebx,[%$dev]
	movzx ebx,word [serial_irq+ebx*2]
	
	; set the DLAB
	invoke serial_in,ebx,SER_OFF_LCR
	or eax,0x80
	invoke serial_out,ebx,SER_OFF_LCR,eax
	
	; set the baudrate divisor
	mov eax,[%$divisor]
	invoke serial_out,ebx,SER_OFF_DLL,eax
	shr eax,8
	invoke serial_out,ebx,SER_OFF_DLH,eax
	
	; clear the DLAB and set line control options
	mov eax,[%$config]
	invoke serial_out,ebx,SER_OFF_LCR,eax
	
	; no interrupts (for now)
	invoke serial_out,ebx,SER_OFF_IER,0x00
	
	; clear and enable the FIFOs
	invoke serial_out,ebx,SER_OFF_FCR,0b11100111
	
	; set the MCR to autoflow control
	invoke serial_out,ebx,SER_OFF_MCR,0b00100000
	
func_end
	
	
func serial_send
	params dev,chr
	save ebx
	
	mov ebx,[%$dev]
	movzx ebx,word [serial_irq+ebx*2]
	
.send_wait:
	invoke serial_in,ebx,SER_OFF_LSR
	test eax,0x20
	jz .send_wait
	
	mov eax,[%$chr]
	invoke serial_out,ebx,SER_OFF_THR,eax
	
func_end
	
	
func serial_recv
	params dev
	save ebx
	
	mov ebx,[%$dev]
	movzx ebx,word [serial_irq+ebx*2]
	
.recv_wait:
	invoke serial_in,ebx,SER_OFF_LSR
	test eax,0x01
	jz .recv_wait
	
	xor eax,eax
	invoke serial_in,ebx,SER_OFF_THR
	
func_end
	
	
func serial_in
	params base,offset
	
	mov dx,[%$base]
	add dx,[%$offset]
	
	xor eax,eax
	in al,dx
	
func_end
	
	
func serial_out
	params base,offset,value
	
	mov dx,[%$base]
	add dx,[%$offset]
	
	mov al,[%$value]
	out dx,al
	
func_end
	
	
	section .bss
	
gdata serial_irq
	resw 4
