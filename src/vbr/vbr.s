%include 'common/header.s'
%include 'common/macro.s'
%include 'common/fat.s'
	
	cpu 386
	bits 16
	
	
	org 0x7c00
	section .text align=1
	
vbr_begin:
	jmp vbr_code
	nop
	
	; BIOS parameter block
vbr_bpb:
.oem_id:
	db "JGsystem"
.byte_per_sector:
	dw 512
.sectors_per_cluster:
	db 1
.reserved_sectors:
	db 1
.nr_fats:
	db 2
.nr_dents:
	dw ???
.nr_sectors
	dw 1440*2
.md_type:
	db FAT_MD_FLOP_1440
.sectors_per_fat:
	dw ???
.sectors_per_track:
	dw 18
.nr_heads:
	dw 2
.nr_hidden_sectors:
	dd 0
.nr_sectors_large:
	dd 0
	
	; extended BIOS parameter block
vbr_ebpb:
.drive_nr:
	db 0x00
.nt_flags:
	db 0x00
.signature:
	db 0x29
.vol_id:
	dd_be 0xdeadbeef
.vol_label:
	db ""
.
	
vbr_code:
	jmp vbr_code
	
vbr_fill:
	fill_to 0x1fe,0x00
	
vbr_flag:
	db 0x55
	db 0xaa
