/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details. */


#ifndef JUSTIX_KERN_CORE_MAIN
#define JUSTIX_KERN_CORE_MAIN

#ifndef __ASSEMBLY__


#include <stdnoreturn.h>


struct mem_map_entry {
	
};


extern void *kern_syscall_stack_top;
extern void *kern_syscall_stack_bottom;

extern struct mem_map_entry *mem_map;


void kern_main(void);
noreturn void kern_die(void);

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
