#ifndef JGSYS_KERN_COMMON_PORT
#define JGSYS_KERN_COMMON_PORT

#ifndef __ASSEMBLY__

#define really_inline static inline __attribute__((always_inline))


really_inline uint8_t inb(uint16_t port) {
	uint8_t val;
	__asm__ __volatile__(
		"inb %1,%0"
		: "=a" (val)
		: "Nd" (port));
	return val;
}

really_inline uint16_t inw(uint16_t port) {
	uint16_t val;
	__asm__ __volatile__(
		"inw %1,%0"
		: "=a" (val)
		: "Nd" (port));
	return val;
}

really_inline uint32_t ind(uint16_t port) {
	uint32_t val;
	__asm__ __volatile__(
		"inl %1,%0"
		: "=a" (val)
		: "Nd" (port));
	return val;
}

really_inline void outb(uint16_t port, uint8_t val) {
	__asm__ __volatile__(
		"outb %0,%w1"
		:
		: "a" (val), "Nd" (port));
}

really_inline void outw(uint16_t port, uint16_t val) {
	__asm__ __volatile__(
		"outw %0,%w1"
		:
		: "a" (val), "Nd" (port));
}

really_inline void outd(uint16_t port, uint32_t val) {
	__asm__ __volatile__(
		"outl %0,%w1"
		:
		: "a" (val), "Nd" (port));
}

really_inline void insb(uint16_t port, uint8_t *dst, uint32_t count) {
	__asm__ __volatile__(
		"cld\n"
		"rep insb"
		: "=D" (dst), "=c" (count)
		: "d" (port), "0" (dst), "1" (count));
}

really_inline void insw(uint16_t port, uint16_t *dst, uint32_t count) {
	__asm__ __volatile__(
		"cld\n"
		"rep insw"
		: "=D" (dst), "=c" (count)
		: "d" (port), "0" (dst), "1" (count));
}

really_inline void insd(uint16_t port, uint32_t *dst, uint32_t count) {
	__asm__ __volatile__(
		"cld\n"
		"rep insl"
		: "=D" (dst), "=c" (count)
		: "d" (port), "0" (dst), "1" (count));
}

really_inline void outsb(uint16_t port, const uint8_t *src, uint32_t count) {
	__asm__ __volatile__(
		"cld\n"
		"rep outsb"
		: "=S" (src), "=c" (count)
		: "d" (port), "0" (src), "1" (count));
}

really_inline void outsw(uint16_t port, const uint16_t *src, uint32_t count) {
	__asm__ __volatile__(
		"cld\n"
		"rep outsw"
		: "=S" (src), "=c" (count)
		: "d" (port), "0" (src), "1" (count));
}

really_inline void outsd(uint16_t port, const uint32_t *src, uint32_t count) {
	__asm__ __volatile__(
		"cld\n"
		"rep outsl"
		: "=S" (src), "=c" (count)
		: "d" (port), "0" (src), "1" (count));
}

#else

%macro outw %1
	
%endm

#endif

#endif
