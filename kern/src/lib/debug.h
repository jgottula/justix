#ifndef JGSYS_KERN_LIB_DEBUG
#define JGSYS_KERN_LIB_DEBUG

#ifndef __ASSEMBLY__

void debug_write_str(const char *str);
void debug_write_fmt(const char *str, ...);
void debug_write_hex4(uint8_t hex);
void debug_write_hex8(uint8_t hex);
void debug_write_hex16(uint16_t hex);
void debug_write_hex32(uint32_t hex);
void debug_write_dec(uint32_t dec);
void debug_stack_trace(void *base_ptr);
void debug_dump_saved_reg(uint32_t *regs);
void debug_dump_mem(void *addr, uint32_t len);

#else

extern debug_write_str
extern debug_write_fmt
extern debug_write_hex4
extern debug_write_hex8
extern debug_write_hex16
extern debug_write_hex32
extern debug_write_dec
extern debug_dump_saved_reg
extern debug_dump_mem

%ifndef jgsys_kern_lib_debug
extern debug_stack_trace
%endif

#endif

#endif
