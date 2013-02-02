#ifndef JGSYS_KERN_COMMON_INLINE
#define JGSYS_KERN_COMMON_INLINE

#ifndef __ASSEMBLY__

#define really_inline static inline __attribute__((always_inline))


really_inline void cli(void) {
	__asm__ __volatile__(
		"cli"
		:
		:
		: "memory");
}

really_inline void sti(void) {
	__asm__ __volatile__(
		"sti"
		:
		:
		: "memory");
}

#endif

#endif
