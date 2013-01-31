#ifndef JGSYS_KERN_LIB_DEBUG
#define JGSYS_KERN_LIB_DEBUG

#ifndef __ASSEMBLY__

void debug_clear_screen(void);
void debug_print_char(char chr);
void debug_print_string(const char *str);
void debug_print_hex8(uint8_t hex);
void debug_print_hex16(uint16_t hex);
void debug_print_hex32(uint32_t hex);
void debug_stack_trace(void *ebp, void *stack_bottom);

#else

#endif

#endif
