%define MBR_OFFSET       0x0c00
%define VBR_OFFSET       0x7c00
%define JGFS_HDR_OFFSET  0x7e00
%define BOOT_OFFSET      0x8000

%define MBR_OFF_PTABLE   0x1b8
%define MBR_OFF_PART1    0x1be
%define MBR_OFF_PART2    0x1ce
%define MBR_OFF_PART3    0x1de
%define MBR_OFF_PART4    0x1ee

%define MBR_PART_SIZE    0x10

%define VBR_OFF_BOOTFLAG 0x1fe

%define BIOS_BOOT_FLAG   0x55aa
