justix
======
`justix` is an experimental PC operating system for Intel 586's, created with
the intent to gain experience with kernel programming, to become more
knowledgeable about the internal workings of standard PC hardware, to have fun,
and, of course, for bragging rights.

`justix` will be at least partially `POSIX`-compatible. It will use `jgfs2` as
its primarily filesystem. The operating system will run on Pentium (mid-1990s
era) or newer PC systems, and will support 32-bit protected mode on one CPU
only. Storage support will be exclusively `ATAPI` at first, for use with ZIP
drives.

The codebase consists primarily of C (C11 with gnu extensions), with some IA-32
assembly (nasm) used primarily in the bootloader and in select places in the
kernel.

status
------

### bootloader ###
Fully functional. Currently supports only legacy `jgfs`.

### kernel ###
Loads protected mode. Serial mostly works. Multitasking partially works.
System calls work but none have been implemented yet.

### userspace ###
Planned. The `gcc` compiler and the `newlib` implementation of `libc` will be
ported to `justix` userspace once multitasking and system calls are sufficiently
functional.

building
--------
To build the kernel and bootloader, simply run `make all`. To clean the project
directory, run `make clean`.

To build individual targets, run one of the following:

- `make boot`: build the bootloader, `boot/out/bin/*`
- `make kern`: build the kernel, `kern/out/kern.bin`
- `make script`: build test scripts written in C, `test/*`

running
-------

### local debugging ###
Run the `setup` script to create a disk image, partition it, and set up a loop
device:

    test/setup

Run the `install` script to make a `jgfs` filesystem on the loop device, copy
the kernel image to the filesystem, and install the bootloader to the device:

    test/install

Run `bochs` using `/dev/loop0` as the primary hard disk.

### real hardware ###
This is slightly harder. Use command line options of the `install` script to
install to a real device. Then, set the target hardware to boot from the disk to
which `justix` has been installed.

directories
-----------
- `boot/out`: bootloader binaries and dumps
- `boot/src`: bootloader source code
- `disasm`: bootloader disassembly dumps
- `doc`: project documentation
- `kern/out`: kernel binary and dumps
- `kern/src`: kernel source code
- `script`: C script source code
- `test`: test scripts, binaries, and images

license
-------
This project is licensed under the terms of the simplified (2-clause) BSD
license. For more information, see the `LICENSE` file contained in the project's
root directory.
