%define BIOS_VID          0x10
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

%define BIOS_DISK           0x13
%define BIOS_DISK_RESET     0x00
%define BIOS_DISK_STATUS    0x01
%define BIOS_DISK_READ      0x02
%define BIOS_DISK_WRITE     0x03
%define BIOS_DISK_PARAM     0x08
%define BIOS_DISK_EXT_CHK   0x41
%define BIOS_DISK_EXT_READ  0x42
%define BIOS_DISK_EXT_WRITE 0x43
%define BIOS_DISK_EXT_PARAM 0x48

%define BLACK     0b0000
%define BLUE      0b0001
%define GREEN     0b0010
%define CYAN      0b0011
%define RED       0b0100
%define MAGENTA   0b0101
%define BROWN     0b0110
%define LTGRAY    0b0111
%define DKGRAY    0b1000
%define LTBLUE    0b1001
%define LTGREEN   0b1010
%define LTCYAN    0b1011
%define LTRED     0b1100
%define LTMAGENTA 0b1101
%define YELLOW    0b1110
%define WHITE     0b1111

%define BIOS_COLOR(_fg, _bg) (_fg | (_bg << 4))

%define BIOS_DADDRPKT_SIZE 0x10
