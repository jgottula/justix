#ifndef JUSTIX_KERN_BUS_PCI
#define JUSTIX_KERN_BUS_PCI

#ifndef __ASSEMBLY__

#define PCI_REG_VEN_ID    0x00
#define PCI_REG_DEV_ID    0x02
#define PCI_REG_CMD       0x04
#define PCI_REG_STATUS    0x06
#define PCI_REG_REV_ID    0x08
#define PCI_REG_PROG_IF   0x09
#define PCI_REG_SUBCLASS  0x0a
#define PCI_REG_CLASS     0x0b
#define PCI_REG_CACHELINE 0x0c
#define PCI_REG_LATEN_TMR 0x0d
#define PCI_REG_HDR_TYPE  0x0e
#define PCI_REG_BIST      0x0f
#define PCI_REG_BAR0      0x10
#define PCI_REG_BAR1      0x14
#define PCI_REG_BAR2      0x18
#define PCI_REG_BAR3      0x1c
#define PCI_REG_BAR4      0x20
#define PCI_REG_BAR5      0x24
#define PCI_REG_CIS_PTR   0x28
#define PCI_REG_SS_VEN_ID 0x2c
#define PCI_REG_SS_ID     0x2e
#define PCI_REG_EXPROM_LO 0x30
#define PCI_REG_EXPROM_HI 0x32
#define PCI_REG_CAP_PTR   0x34
#define PCI_REG_IN_LINE   0x3c
#define PCI_REG_IN_PIN    0x3d
#define PCI_REG_MIN_GRANT 0x3e
#define PCI_REG_MAX_LATEN 0x3f


struct pci_cfg_addr {
	uint32_t rsvd_a   : 2;
	uint32_t reg_num  : 6;
	uint32_t func_num : 3;
	uint32_t dev_num  : 5;
	uint32_t bus_num  : 8;
	uint32_t rsvd_b   : 7;
	uint32_t enable   : 1;
};

struct pci_cmd_word {
	uint16_t io_space      : 1;
	uint16_t mem_space     : 1;
	uint16_t bus_master    : 1;
	uint16_t spec_cycles   : 1;
	uint16_t mwinval_en    : 1;
	uint16_t vga_pal_snoop : 1;
	uint16_t par_err_resp  : 1;
	uint16_t rsvd_a        : 1;
	uint16_t serr_enable   : 1;
	uint16_t fast_b2b_en   : 1;
	uint16_t int_disable   : 1;
	uint16_t rsvd_b        : 5;
};

struct pci_status_reg {
	uint16_t rsvd_a        : 3;
	uint16_t int_status    : 1;
	uint16_t cap_list      : 1;
	uint16_t cap_66mhz     : 1;
	uint16_t rsvd_b        : 1;
	uint16_t fast_b2b_cap  : 1;
	uint16_t mas_par_err   : 1;
	uint16_t devsel_tim    : 2;
	uint16_t sig_targ_ab   : 1;
	uint16_t rcv_targ_ab   : 1;
	uint16_t rcv_master_ab : 1;
	uint16_t sig_sys_err   : 1;
	uint16_t det_par_err   : 1;
};

struct pci_mem_bar {
	uint32_t zero     :  1;
	uint32_t type     :  2;
	uint32_t prefetch :  1;
	uint32_t addr     : 28;
};

struct pci_io_bar {
	uint32_t one  :  1;
	uint32_t rsvd :  1;
	uint32_t addr : 30;
};

enum pci_class {
	PCI_CLASS_OLD          = 0x00,
	PCI_CLASS_DISK_CTRLR   = 0x01,
	PCI_CLASS_NET_CTRLR    = 0x02,
	PCI_CLASS_DISP_CTRLR   = 0x03,
	PCI_CLASS_MM_CTRLR     = 0x04,
	PCI_CLASS_MEM_CTRLR    = 0x05,
	PCI_CLASS_BRIDGE       = 0x06,
	PCI_CLASS_SCOMM_CTRLR  = 0x07,
	PCI_CLASS_BASE_PERIPH  = 0x08,
	PCI_CLASS_INPUT_DEV    = 0x09,
	PCI_CLASS_DOCK_STN     = 0x0a,
	PCI_CLASS_CPU          = 0x0b,
	PCI_CLASS_SER_CTRLR    = 0x0c,
	PCI_CLASS_WRLS_CTRLR   = 0x0d,
	PCI_CLASS_INT_IO_CTRLR = 0x0e,
	PCI_CLASS_SATCOM_CTRLR = 0x0f,
	PCI_CLASS_ENCDEC_CTRLR = 0x10,
	PCI_CLASS_DASP_CTRLR   = 0x11,
	PCI_CLASS_UNDEFINED    = 0xff,
};

enum pci_subclass {
	PCI_DISK_SCSI  = 0x00,
	PCI_DISK_IDE   = 0x01,
	PCI_DISK_FLOP  = 0x02,
	PCI_DISK_IPI   = 0x03,
	PCI_DISK_RAID  = 0x04,
	PCI_DISK_ATA   = 0x05,
	PCI_DISK_SATA  = 0x06,
	PCI_DISK_SAS   = 0x07,
	PCI_DISK_OTHER = 0x80,
	
	
};


void pci_enum(void);

#else

extern pci_enum

#endif

#endif
