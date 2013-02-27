/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details. */


#ifndef JUSTIX_KERN_CORE_IDT
#define JUSTIX_KERN_CORE_IDT

#ifndef __ASSEMBLY__

struct idt_entry {
	uint16_t offset_low  : 16;
	uint16_t selector    : 16;
	uint8_t  zero        :  8;
	uint8_t  type        :  4;
	uint8_t  stor_seg    :  1;
	uint8_t  priv_lvl    :  2;
	uint8_t  present     :  1;
	uint16_t offset_high : 16;
};


extern struct idt_entry idt_table;

#else

%ifndef justix_kern_core_idt
extern idt_table

extern idt_setup
%endif

#endif

#endif
