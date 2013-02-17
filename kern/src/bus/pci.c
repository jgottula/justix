#include "bus/pci.h"
#include "common/port.h"
#include "lib/debug.h"


static uint16_t pci_read_config_word(uint8_t bus, uint8_t dev, uint8_t func,
	uint8_t offset) {
	/* avoid strict aliasing problems by cleverly using a union */
	struct pci_cfg_addr addr = {
		.bus_num  = bus,
		.dev_num  = dev,
		.func_num = func,
		.reg_num  = offset & ~0x03,
	};
	
	outd(0xcf8, *((uint32_t *)&addr));
	return (ind(0xcfc) >> ((offset & 0x03) * 8));
}

static void pci_check_func(uint8_t bus, uint8_t dev, uint8_t func) {
	uint16_t class_word =
		pci_read_config_word(bus, dev, func, PCI_REG_SUBCLASS);
	uint8_t class = class_word >> 8, subclass = class_word & 0xff;
	
	debug_write_fmt("found pci device: bus %xb dev %xb func %xb\n",
		bus, dev, func);
	
	if (class == PCI_CLASS_DISK_CTRLR) {
		debug_write_str("found disk controller\n");
		
		for (uint8_t offset = 0; offset < 0x40; offset += 2) {
			uint16_t word = pci_read_config_word(bus, dev, func, offset);
			
			debug_write_fmt("%xb: %xw\n", offset, word);
		}
	}
}

static void pci_check_dev(uint8_t bus, uint8_t dev) {
	uint8_t func = 0;
	
	uint16_t vid = pci_read_config_word(bus, dev, func, PCI_REG_VEN_ID);
	
	if (vid != 0xffff) {
		pci_check_func(bus, dev, func);
		
		uint8_t hdr_type =
			pci_read_config_word(bus, dev, func, PCI_REG_HDR_TYPE);
		
		/* device is multi-function; check other functions */
		if ((hdr_type & 0x80) != 0) {
			for (func = 1; func < 8; ++func) {
				if ((vid = pci_read_config_word(bus, dev, func,
					PCI_REG_VEN_ID)) != 0xffff) {
					pci_check_func(bus, dev, func);
				}
			}
		}
	}
}

void pci_enum(void) {
	uint8_t bus = 0x00;
	
	/* brute force method of pci enumeration: try all possible devices */
	do {
		uint8_t dev = 0x00;
		
		do {
			pci_check_dev(bus, dev);
		} while (dev++ != 0x1f);
	} while (bus++ != 0xff);
}
