#ifndef JGSYS_KERN_LIB_STRING
#define JGSYS_KERN_LIB_STRING

#ifndef __ASSEMBLY__

uint32_t strlen(const char *s);
int32_t strcmp(const char *restrict s1, const char *restrict s2);
uint8_t memcmp(const uint8_t *restrict m1, const uint8_t *restrict m2,
	uint32_t size);
void memset(const uint8_t *mem, uint8_t val, uint32_t size);
void memcpy(uint8_t *restrict dst, const uint8_t *restrict src, uint32_t size);

#else

%ifndef jgsys_kern_lib_string
extern strlen
extern strcmp
extern memcmp
extern memset
extern memcpy
%endif

#endif

#endif
