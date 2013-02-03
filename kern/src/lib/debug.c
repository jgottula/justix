#include <lib/debug.h>
#include <stdarg.h>
#include <serial/serial.h>


void debug_write_chr(char chr) {
	serial_send(0, chr);
}

void debug_write_str(const char *str) {
	serial_send_str(0, str);
}

void debug_write_fmt(const char *str, ...) {
	va_list fmt;
	va_start(fmt, str);
	
	while (*str != '\0') {
		if (*str == '%') {
			switch (str[1]) {
			case '\0':
				++str;
				continue;
			case '%':
				debug_write_chr('%');
				break;
			case 'x':
				if (str[2] == 'b') {
					debug_write_hex8(va_arg(fmt, uint32_t));
				} else if (str[2] == 'w') {
					debug_write_hex16(va_arg(fmt, uint32_t));
				} else if (str[2] == 'd') {
					debug_write_hex32(va_arg(fmt, uint32_t));
				}
				++str;
				break;
			case 'i':
				debug_write_dec(va_arg(fmt, uint32_t));
				break;
			case 's':
				debug_write_str(va_arg(fmt, const char *));
				break;
			default:
				/* explicitly discard the next parameter of unknown type */
				(void)va_arg(fmt, uint32_t);
			}
			
			str += 2;
		} else {
			debug_write_chr(*str);
			
			++str;
		}
	}
	
	va_end(fmt);
}

void debug_write_hex4(uint8_t hex) {
	hex &= 0x0f;
	
	if (hex < 0xa) {
		debug_write_chr(hex + '0');
	} else {
		debug_write_chr((hex - 0xa) + 'a');
	}
}

void debug_write_hex8(uint8_t hex) {
	debug_write_hex4(hex >> 4);
	debug_write_hex4(hex);
}

void debug_write_hex16(uint16_t hex) {
	debug_write_hex8(hex >> 8);
	debug_write_hex8(hex);
}

void debug_write_hex32(uint32_t hex) {
	debug_write_hex16(hex >> 16);
	debug_write_hex16(hex);
}

void debug_write_dec(uint32_t dec) {
	uint32_t divisor = 1000 * 1000 * 1000;
	bool digit_yet = false;
	
	do {
		uint32_t digit = dec / divisor;
		dec %= divisor;
		
		if (digit != 0 || digit_yet || divisor == 1) {
			debug_write_chr(digit + '0');
			digit_yet = true;
		}
		
		divisor /= 10;		
	} while (divisor >= 1);
}

void debug_dump_saved_reg(uint32_t *regs) {
	/* registers in ascending order in memory:
	 * edi esi ebp esp ebx edx ecx eax eflags */
	
	debug_write_str("registers:\n");
	
	debug_write_fmt("eax    %xd\n", regs[7]);
	debug_write_fmt("ebx    %xd\n", regs[4]);
	debug_write_fmt("ecx    %xd\n", regs[6]);
	debug_write_fmt("edx    %xd\n", regs[5]);
	debug_write_fmt("esi    %xd\n", regs[1]);
	debug_write_fmt("edi    %xd\n", regs[0]);
	debug_write_fmt("ebp    %xd\n", regs[2]);
	debug_write_fmt("esp    %xd\n", regs[3]);
	debug_write_fmt("eflags %xd\n", regs[8]);
}

void debug_dump_mem(void *addr, uint32_t len) {
	uintptr_t start = (uintptr_t)addr & ~0xf;
	uintptr_t end   = (uintptr_t)((uint8_t *)addr + len);
	
	if ((end & 0xf) != 0) {
		end &= 0xf;
		end += 0x10;
	}
	
	debug_write_fmt("mem dump @ %xd (len %xd):\n", addr, len);
	
	uint8_t *ptr = (uint8_t *)start;
	uint32_t i   = 0;
	
	while (ptr != (uint8_t *)end) {
		if (i == 0) {
			debug_write_fmt("%xd: ", ptr);
		} else if (i == 8) {
			debug_write_chr(' ');
		} else if (i == 15) {
			debug_write_chr('\n');
		}
		
		debug_write_fmt(" %xb", *ptr);
		
		++ptr;
		if (++i >= 0x10) {
			i = 0;
		}
	}
}
