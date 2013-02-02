%define MBR_OFFSET            0x0c00
%define JGFS_SECT_OFFSET      0x0e00
%define JGFS_CLUST_OFFSET     0x1000
%define MEM_MAP_OFFSET        0x7000
%define VBR_OFFSET            0x7c00
%define JGFS_HDR_OFFSET       0x7e00
%define BOOT_OFFSET           0x8000
%define JGFS_FAT_BMP_OFFSET  0x10000
%define JGFS_FAT_OFFSET      0x10200
%define KERN_OFFSET         0x100000

%define MBR_SIZE            0x0200
%define MBR_CODE_SIZE       0x01b8
%define VBR_SIZE            0x0200
%define BOOT_SIZE           0x1000

%define MBR_ENTRY           0x7c00

%define STACK_ADDR          0x7c00

%define MBR_OFF_PTABLE      0x01b8
%define MBR_OFF_PART1       0x01be
%define MBR_OFF_PART2       0x01ce
%define MBR_OFF_PART3       0x01de
%define MBR_OFF_PART4       0x01ee

%define MBR_PART_SIZE       0x0010
%define MBR_PART_OFF_LBA    0x0008

%define VBR_OFF_BOOTFLAG    0x01fe

%define BIOS_BOOT_FLAG      0x55aa
