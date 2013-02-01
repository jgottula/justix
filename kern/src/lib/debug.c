#include <lib/debug.h>
#include <serial/serial.h>


void debug_write_chr(char chr) {
	serial_send(0, chr);
}

void debug_write_str(const char *str) {
	serial_send_str(0, str);
}

void debug_write_hex4(uint8_t hex) {
	hex &= 0x0f;
	
	if (hex < 0xa) {
		debug_write_chr(hex + '0');
	} else {
		debug_write_chr(hex + 'a');
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
