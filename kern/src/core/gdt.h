#ifndef JGSYS_KERN_CORE_GDT
#define JGSYS_KERN_CORE_GDT

#ifndef __ASSEMBLY__

#define GDT_ACC_AC    0x01
#define GDT_ACC_RW    0x02
#define GDT_ACC_DC    0x04
#define GDT_ACC_EX    0x08
#define GDT_ACC_PRIVL 0x60
#define GDT_ACC_PR    0x80

#define GDT_FL_GR     0x80
#define GDT_FL_SZ     0x40

#define SEG_NULL      0x00
#define SEG_KERN_DATA 0x08
#define SEG_KERN_CODE 0x10
#define SEG_USER_DATA 0x18
#define SEG_USER_CODE 0x20

#else

%assign GDT_ACC_AC    0x01
%assign GDT_ACC_RW    0x02
%assign GDT_ACC_DC    0x04
%assign GDT_ACC_EX    0x08
%assign GDT_ACC_PRIVL 0x60
%assign GDT_ACC_PR    0x80

%assign GDT_FL_GR     0x80
%assign GDT_FL_SZ     0x40

%assign SEG_NULL      0x00
%assign SEG_KERN_DATA 0x08
%assign SEG_KERN_CODE 0x10
%assign SEG_USER_DATA 0x18
%assign SEG_USER_CODE 0x20

%ifndef jgsys_kern_core_gdt
extern gdt_setup
%endif

/* TODO */
/*struc gdt_entry
.member: resb 1
endstruc*/

#endif

#endif
