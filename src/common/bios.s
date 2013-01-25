%define BIOS_VID_STR 0x13

%define BIOS_DISK_RESET  0x00
%define BIOS_DISK_STATUS 0x01
%define BIOS_DISK_READ   0x02

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
