/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */

#ifndef JUSTIX_KERN_PLATFORM_PIC
#define JUSTIX_KERN_PLATFORM_PIC

#ifndef __ASSEMBLY__

enum pic_port {
	PIC_MASTER_CMD  = 0x0020,
	PIC_MASTER_DATA = 0x0021,
	PIC_SLAVE_CMD   = 0x00a0,
	PIC_SLAVE_DATA  = 0x00a1,
};

enum pic_cmd {
	PIC_CMD_EOI = 0x20,
};


void pic_init(void);
void pic_enable(uint8_t irq);
void pic_disable(uint8_t irq);
void pic_eoi(uint8_t irq);

#else

extern pic_init
extern pic_enable
extern pic_disable
extern pic_eoi

#endif

#endif
