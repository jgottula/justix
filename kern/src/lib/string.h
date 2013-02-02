#ifndef JGSYS_KERN_LIB_STRING
#define JGSYS_KERN_LIB_STRING

#ifndef __ASSEMBLY__

uint32_t strlen(const char *s);
int32_t strcmp(const char *restrict s1, const char *restrict s2);
uint8_t memcmp(const void *restrict m1, const void *restrict m2, uint32_t size);
void memset(void *mem, uint8_t val, uint32_t size);
void memcpy(void *restrict dst, const void *restrict src, uint32_t size);

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
