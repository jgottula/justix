#ifndef JGSYS_KERN_CORE_INIT
#define JGSYS_KERN_CORE_INIT

#ifndef __ASSEMBLY__

#define MEM_MAP_OFFSET 0x7000

#else

%assign MEM_MAP_OFFSET 0x7000

%ifndef jgsys_kern_core_init
extern kern_entry
extern kern_die

extern kern_stack_top
extern kern_stack_bottom
extern kern_mem_map
%endif

#endif

#endif
