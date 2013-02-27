/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */

#ifndef JUSTIX_KERN_CORE_TASK
#define JUSTIX_KERN_CORE_TASK

#ifndef __ASSEMBLY__

struct tss_entry {
	uint32_t prev_tss;
	uint32_t esp0;
	uint32_t ss0;
	uint32_t esp1;
	uint32_t ss1;
	uint32_t esp2;
	uint32_t ss2;
	uint32_t cr3;
	uint32_t eip;
	uint32_t eflags;
	uint32_t eax;
	uint32_t ecx;
	uint32_t edx;
	uint32_t ebx;
	uint32_t esp;
	uint32_t ebp;
	uint32_t esi;
	uint32_t edi;
	uint32_t es;
	uint32_t cs;
	uint32_t ss;
	uint32_t ds;
	uint32_t fs;
	uint32_t gs;
	uint32_t lds;
	uint16_t trap;
	uint16_t iomap_base;
};


void task_init(void);
void task_flush_tss(void);
void task_enter_ring3(void *addr);

#else

extern tss_init

%ifndef justix_kern_core_task
extern user_stack_top
extern user_stack_bottom

extern task_flush_tss
extern task_enter_ring3
%endif

#endif

#endif
