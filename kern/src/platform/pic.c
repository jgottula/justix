/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */


#include "platform/pic.h"
#include "common/port.h"


void pic_init(void) {
	outb(PIC_MASTER_CMD, 0x11);
	outb(PIC_SLAVE_CMD, 0x11);
	
	outb(PIC_MASTER_DATA, 0x20);
	outb(PIC_SLAVE_DATA, 0x28);
	
	outb(PIC_MASTER_DATA, 4);
	outb(PIC_SLAVE_DATA, 2);
	
	outb(PIC_MASTER_DATA, 0x01);
	outb(PIC_SLAVE_DATA, 0x01);
	
	/* disable all */
	outb(PIC_MASTER_DATA, 0xff);
	outb(PIC_SLAVE_DATA, 0xff);
}

void pic_enable(uint8_t irq) {
	if (irq < 8) {
		uint8_t mask = inb(PIC_MASTER_DATA);
		outb(PIC_MASTER_DATA, mask & ~_BV(irq));
	} else if (irq < 16) {
		uint8_t mask = inb(PIC_SLAVE_DATA);
		outb(PIC_SLAVE_DATA, mask & ~_BV(irq - 8));
	}
}

void pic_disable(uint8_t irq) {
	if (irq < 8) {
		uint8_t mask = inb(PIC_MASTER_DATA);
		outb(PIC_MASTER_DATA, mask | _BV(irq));
	} else if (irq < 16) {
		uint8_t mask = inb(PIC_SLAVE_DATA);
		outb(PIC_SLAVE_DATA, mask | _BV(irq - 8));
	}
}

void pic_eoi(uint8_t irq) {
	if (irq >= 8) {
		outb(PIC_SLAVE_CMD, PIC_CMD_EOI);
	}
	
	outb(PIC_MASTER_CMD, PIC_CMD_EOI);
}
