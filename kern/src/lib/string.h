#ifndef JGSYS_KERN_LIB_STRING
#define JGSYS_KERN_LIB_STRING

#ifndef __ASSEMBLY__

#include <stdbool.h>
#include <stdint.h>


uint32_t strlen(const char *s);
int32_t  strcmp(const char *restrict s1, const char *restrict s2);
uint8_t  memcmp(const uint8_t *restrict m1, const uint8_t *restrict m2,
	uint32_t size);

#else

%ifndef jgsys_kern_lib_string
extern strlen
extern strcmp
extern memcmp
%endif

#endif

#endif
