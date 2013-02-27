/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */


#include "lib/string.h"


uint32_t strlen(const char *str) {
	const char *ptr = str;
	while (*(ptr++) != '\0');
	
	return (ptr - str) - 1;
}

int32_t strcmp(const char *str1, const char *str2) {
	char c1, c2;
	
	do {
		c1 = *(str1++);
		c2 = *(str2++);
	} while (c1 == c2 && c1 != '\0');
	
	return (c1 - c2);
}

void strcpy(char *restrict dst, const char *restrict src) {
	char c;
	
	do {
		c = *(src++);
		*(dst++) = c;
	} while (c != '\0');
}

void memset(void *mem, uint8_t val, uint32_t size) {
	uint8_t *ptr = mem;
	
	while (size-- != 0) {
		*(ptr++) = val;
	}
}

uint8_t memcmp(const void *mem1, const void *mem2, uint32_t size) {
	const uint8_t *ptr1 = mem1, *ptr2 = mem2;
	uint8_t b1, b2;
	
	while (size-- != 0) {
		b1 = *(ptr1++);
		b2 = *(ptr2++);
		
		if (b1 != b2) {
			return (b1 - b2);
		}
	}
	
	return 0;
}

void memcpy(void *restrict dst, const void *restrict src, uint32_t size) {
	uint8_t *restrict p_dst = dst;
	const uint8_t *restrict p_src = src;
	
	while (size-- != 0) {
		*(p_dst++) = *(p_src++);
	}
}
