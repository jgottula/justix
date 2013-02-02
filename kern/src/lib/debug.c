#include <lib/debug.h>
#include <serial/serial.h>


void debug_write_chr(char chr) {
	serial_send(0, chr);
}

void debug_write_str(const char *str) {
	serial_send_str(0, str);
}

void debug_write_fmt(const char *str, ...) {
	uint32_t *arg = (uint32_t *)&str + 1;
	
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
					debug_write_hex8(*(arg++));
				} else if (str[2] == 'w') {
					debug_write_hex16(*(arg++));
				} else if (str[2] == 'd') {
					debug_write_hex32(*(arg++));
				}
				++str;
				break;
			case 'i':
				debug_write_dec(*(arg++));
				break;
			default:
				++arg;
			}
			
			str += 2;
		} else {
			debug_write_chr(*str);
			
			++str;
		}
	}
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
