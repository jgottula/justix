/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */


//#include "debug/debug.h"
#include "serial/serial.h"
#include "core/idt.h"

void putDebugChar(int c) {
	serial_send(0, c);
}

int getDebugChar(void) {
	char c;
	while (!serial_recv(0, (uint8_t *)&c));
	
	return c;
}

void exceptionHandler(int num, void *addr) {
	struct idt_entry *idt = &idt_table + num;
	
	idt->offset_low  = (intptr_t)addr;
	idt->offset_high = (intptr_t)addr >> 16;
}
