#ifndef JGSYS_KERN_COMMON_SYNC
#define JGSYS_KERN_COMMON_SYNC

#ifndef __ASSEMBLY__

#include "common/inline.h"


/* disallow unaligned reads/writes of mutexes */
typedef volatile uint32_t mutex_t __attribute__((aligned(sizeof(uint32_t))));


#define really_inline static inline __attribute__((always_inline))


really_inline void atomic_inc(uint32_t *mem) {
	__asm__ __volatile__(
		"lock incl (%0)"
		:
		: "m" (mem)
		: "memory");
}

really_inline void lock(mutex_t *mutex) {
	while (!__sync_bool_compare_and_swap(mutex, 0, 1));
}

really_inline void unlock(mutex_t *mutex) {
	mem_barrier();
	
	*mutex = 0;
}

#endif

#endif
