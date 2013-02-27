/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */


#ifndef JUSTIX_KERN_COMMON_INLINE
#define JUSTIX_KERN_COMMON_INLINE

#ifndef __ASSEMBLY__

#define really_inline static inline __attribute__((always_inline))


really_inline void mem_barrier(void) {
	__asm__ __volatile__(
		""
		:
		:
		: "memory");
}

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

really_inline void breakpoint(void) {
	__asm__ __volatile__(
		"int $0x03"
		:
		:
		: "memory");
}

really_inline uint32_t flags_save(void) {
	uint32_t eflags;
	
	__asm__ __volatile__(
		"pushf\n"
		"pop %0"
		: "=rm" (eflags)
		:
		: "memory");
	
	return eflags;
}

really_inline void flags_restore(uint32_t eflags) {
	__asm__ __volatile__(
		"push %0\n"
		"popf"
		:
		: "g" (eflags)
		: "memory");
}

really_inline uint32_t cli_save(void) {
	uint32_t eflags = flags_save();
	cli();
	
	return eflags;
}

really_inline void int_restore(uint32_t eflags) {
	flags_restore(eflags);
}

#endif

#endif
