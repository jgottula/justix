#ifndef JUSTIX_KERN_CORE_MAIN
#define JUSTIX_KERN_CORE_MAIN

#ifndef __ASSEMBLY__

struct mem_map_entry {
	
};


extern void *kern_syscall_stack_top;
extern void *kern_syscall_stack_bottom;

extern struct mem_map_entry *mem_map;


void kern_main(void);
void kern_die(void);

void user_test(void);

#else

extern kern_mem_map

extern kern_main

%ifndef justix_kern_core_main
extern kern_syscall_stack_top
extern kern_syscall_stack_bottom

extern kern_die
%endif


#endif

#endif
