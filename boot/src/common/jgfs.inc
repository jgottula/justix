%define JGFS_MAGIC          `JGFS`
%define JGFS_VER_MAJOR        0x03
%define JGFS_VER_MINOR        0x01

%define JGFS_HDR_OFF_S_TOTAL 0x006
%define JGFS_HDR_OFF_S_RSVD  0x00a
%define JGFS_HDR_OFF_S_FAT   0x00c

%define JGFS_HDR_OFF_S_PER_C 0x00e

%define JGFS_HDR_OFF_ROOT_DE 0x010

%define JGFS_DC_OFF_FIRST_DE 0x000

%define JGFS_DE_SIZE          0x20
%define JGFS_DE_OFF_NAME      0x00
%define JGFS_DE_OFF_TYPE      0x14
%define JGFS_DE_OFF_ATTR      0x15
%define JGFS_DE_OFF_MTIME     0x16
%define JGFS_DE_OFF_SIZE      0x1a
%define JGFS_DE_OFF_BEGIN     0x1e

%define JGFS_NAME_LIMIT         19

%define JGFS_FAT_FREE       0x0000
%define JGFS_FAT_ROOT       0x0000
%define JGFS_FAT_FIRST      0x0001
%define JGFS_FAT_LAST       0xfffb
%define JGFS_FAT_EOF        0xfffc
%define JGFS_FAT_RSVD       0xfffd
%define JGFS_FAT_BAD        0xfffe
%define JGFS_FAT_OOB        0xffff
%define JGFS_FAT_NALLOC     0xffff

%define JGFS_TYPE_FILE        0x01
%define JGFS_TYPE_DIR         0x02
%define JGFS_TYPE_SYMLINK     0x04
