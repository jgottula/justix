/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */


#ifndef JUSTIX_KERN_LIB_STRING
#define JUSTIX_KERN_LIB_STRING

#ifndef __ASSEMBLY__

uint32_t strlen(const char *str);
int32_t strcmp(const char *str1, const char *str2);
void strcpy(char *restrict dst, const char *restrict src);
void memset(void *mem, uint8_t val, uint32_t size);
uint8_t memcmp(const void *mem1, const void *mem2, uint32_t size);
void memcpy(void *restrict dst, const void *restrict src, uint32_t size);

#else

extern strlen
extern strcmp
extern strcpy
extern memset
extern memcmp
extern memcpy

#endif

#endif
