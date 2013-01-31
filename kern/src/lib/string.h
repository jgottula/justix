#ifndef JGSYS_KERN_LIB_STRING
#define JGSYS_KERN_LIB_STRING


#include <stdbool.h>
#include <stdint.h>


uint32_t strlen(const char *str);
int32_t  strcmp(const char *restrict str1, const char *restrict str2);
uint8_t  memcmp(const uint8_t *restrict ptr1, const uint8_t *restrict ptr2,
	uint32_t size);


#endif
