; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.


%define JGFS_MAGIC          `JGFS`
%define JGFS_VER_MAJOR        0x04
%define JGFS_VER_MINOR        0x01
%define JGFS_VER_TOTAL      0x0401

%define JGFS_HDR_OFF_S_TOTAL 0x006
%define JGFS_HDR_OFF_S_BOOT  0x00a
%define JGFS_HDR_OFF_S_FAT   0x00c

%define JGFS_HDR_OFF_S_PER_C 0x00e

%define JGFS_HDR_OFF_ROOT_DE 0x02c

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

%define JGFS_FENT_PER_SECT   0x100
%define JGFS_MAX_FAT_SECT    0x100

%define JGFS_VBR_SECT            0
%define JGFS_HDR_SECT            1
%define JGFS_BOOT_SECT           2

%define JGFS_ERR_INT13        0x01
%define JGFS_ERR_BOUNDS_SECT  0x02
%define JGFS_ERR_BOUNDS_FAT   0x03
%define JGFS_ERR_FAT_CHAIN    0x04
