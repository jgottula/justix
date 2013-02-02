#ifndef JGSYS_KERN_CORE_MAIN
#define JGSYS_KERN_CORE_MAIN

#ifndef __ASSEMBLY__

struct mem_map_entry {
	
};


extern struct mem_map_entry *mem_map;


void kern_main(void);
void kern_die(void);

#else

extern kern_main

%ifndef jgsys_kern_core_main
extern kern_die
%endif

extern kern_mem_map

#endif

#endif
