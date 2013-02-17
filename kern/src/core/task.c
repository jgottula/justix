#include "core/task.h"
#include "core/main.h"
#include "core/gdt.h"
#include "lib/string.h"


struct tss_entry tss_user;


void task_init(void) {
	uintptr_t base  = (uintptr_t)&tss_user;
	uintptr_t limit = sizeof(tss_user);
	struct gdt_entry gdt_tss = {
		.limit_low    = limit,
		.base_low     = base,
		.base_med     = (base >> 16),
		.access_ac    = 1,
		.access_rw    = 0,
		.access_dc    = 0,
		.access_ex    = 1,
		.access_type  = 0,
		.access_privl = 3,
		.access_pr    = 1,
		.limit_high   = (limit >> 16),
		.flags_zero   = 0,
		.flags_sz     = 1,
		.flags_gr     = 0,
		.base_high    = (base >> 24),
	};
	
	(&gdt_table)[SEL_TSS] = gdt_tss;
	
	memset(&tss_user, 0, sizeof(tss_user));
	tss_user.ss0        = SEL_KERN_DATA * 8;
	tss_user.esp0       = (uint32_t)&kern_syscall_stack_bottom;
	tss_user.iomap_base = sizeof(tss_user);
	
	task_flush_tss();
}
