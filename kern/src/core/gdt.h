#ifndef JUSTIX_KERN_CORE_GDT
#define JUSTIX_KERN_CORE_GDT

#ifndef __ASSEMBLY__

#define GDT_ACC_AC    0x01
#define GDT_ACC_RW    0x02
#define GDT_ACC_DC    0x04
#define GDT_ACC_EX    0x08
#define GDT_ACC_PRIVL 0x60
#define GDT_ACC_PR    0x80

#define GDT_FL_GR     0x80
#define GDT_FL_SZ     0x40

#define SEL_NULL      0
#define SEL_KERN_DATA 1
#define SEL_KERN_CODE 2
#define SEL_USER_DATA 3
#define SEL_USER_CODE 4
#define SEL_TSS       5


struct gdt_entry {
	uint16_t limit_low    : 16;
	uint16_t base_low     : 16;
	uint8_t  base_med     :  8;
	uint8_t  access_ac    :  1;
	uint8_t  access_rw    :  1;
	uint8_t  access_dc    :  1;
	uint8_t  access_ex    :  1;
	uint8_t  access_type  :  1;
	uint8_t  access_privl :  2;
	uint8_t  access_pr    :  1;
	uint8_t  limit_high   :  4;
	uint8_t  flags_zero   :  2;
	uint8_t  flags_sz     :  1;
	uint8_t  flags_gr     :  1;
	uint8_t  base_high    :  8;
};


extern struct gdt_entry gdt_table;

#else

%assign GDT_ACC_AC    0x01
%assign GDT_ACC_RW    0x02
%assign GDT_ACC_DC    0x04
%assign GDT_ACC_EX    0x08
%assign GDT_ACC_PRIVL 0x60
%assign GDT_ACC_PR    0x80

%assign GDT_FL_GR     0x80
%assign GDT_FL_SZ     0x40

%assign SEL_NULL      0x00
%assign SEL_KERN_DATA 0x08
%assign SEL_KERN_CODE 0x10
%assign SEL_USER_DATA 0x18
%assign SEL_USER_CODE 0x20
%assign SEL_TSS       0x28

%ifndef justix_kern_core_gdt
extern gdt_table

extern gdt_setup
%endif

/* TODO */
/*struc gdt_entry
.member: resb 1
endstruc*/

#endif

#endif
