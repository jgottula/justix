#ifndef JGSYS_KERN_LIB_DEBUG
#define JGSYS_KERN_LIB_DEBUG

#ifndef __ASSEMBLY__

#include <stdbool.h>
#include <stdint.h>


void debug_write_str(const char *str);
void debug_write_hex4(uint8_t hex);
void debug_write_hex8(uint8_t hex);
void debug_write_hex16(uint16_t hex);
void debug_write_hex32(uint32_t hex);
void debug_stack_trace(void *ebp, void *stack_bottom);

#else

%ifndef jgsys_kern_lib_debug
extern debug_write_str
extern debug_write_hex4
extern debug_write_hex8
extern debug_write_hex16
extern debug_write_hex32
extern debug_stack_trace
%endif

#endif

#endif
