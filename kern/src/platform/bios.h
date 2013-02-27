/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details. */


#ifndef JUSTIX_KERN_PLATFORM_BIOS
#define JUSTIX_KERN_PLATFORM_BIOS

#ifndef __ASSEMBLY__

static struct {
	volatile uint16_t *com_port[4];
} bios_data = {
	.com_port[0] = (void *)0x0400,
	.com_port[1] = (void *)0x0402,
	.com_port[2] = (void *)0x0404,
	.com_port[3] = (void *)0x0406,
};

#else

#endif

#endif
