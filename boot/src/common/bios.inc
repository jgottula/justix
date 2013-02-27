; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.


%define BIOS_VID_SETMODE  0x00
%define BIOS_VID_CUR      0x01
%define BIOS_VID_SETCUR   0x02
%define BIOS_VID_GETCUR   0x03
%define BIOS_VID_PAGE     0x05
%define BIOS_VID_GETCHATT 0x08
%define BIOS_VID_PUTCHATT 0x09
%define BIOS_VID_PUTCHAR  0x0a
%define BIOS_VID_TELETYPE 0x0e
%define BIOS_VID_SETMODE  0x0f
%define BIOS_VID_STR      0x13

%define BIOS_DISK_RESET     0x00
%define BIOS_DISK_STATUS    0x01
%define BIOS_DISK_READ      0x02
%define BIOS_DISK_WRITE     0x03
%define BIOS_DISK_PARAM     0x08
%define BIOS_DISK_EXT_CHK   0x41
%define BIOS_DISK_EXT_READ  0x42
%define BIOS_DISK_EXT_WRITE 0x43
%define BIOS_DISK_EXT_PARAM 0x48

%define BIOS_SYS_A20_ENABLE 0x2401
%define BIOS_SYS_A20_STATUS 0x2402
%define BIOS_SYS_MEM_MAP    0xe820

%define BIOS_DADDRPKT_SIZE 0x10

%define BIOS_MEM_USABLE       1
%define BIOS_MEM_RESERVED     2
%define BIOS_MEM_ACPI_RECLAIM 3
%define BIOS_MEM_ACPI_NVS     4
%define BIOS_MEM_BAD_RAM      5
