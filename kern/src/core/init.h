#ifndef JGSYS_KERN_CORE_INIT
#define JGSYS_KERN_CORE_INIT

#ifndef __ASSEMBLY__

#define MEM_MAP_OFFSET 0x7000

#else

%assign MEM_MAP_OFFSET 0x7000

extern _BSS_START
extern _BSS_SIZE

%ifndef jgsys_kern_core_init
extern kern_entry

extern kern_stack_top
extern kern_stack_bottom
%endif

#endif

#endif
