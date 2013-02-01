#include <serial/serial.h>


void serial_send_str(uint8_t dev, const char *str) {
	while (*str != '\0') {
		serial_send(dev, *(str++));
	}
}
