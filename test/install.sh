#!/bin/sh

DEV="/dev/loop0"
PART="/dev/loop0p1"
MOUNT="/tmp/jgfs"

usage() {
  echo "usage: $0 [dev=] [part=] [mount=] [bochs|eject]"
  exit 1
}

if [[ "$1" == "dev="* ]]; then
	DEV="/dev/${1#dev=}"
	shift
	
	echo "Using $DEV as device"
fi

if [[ "$1" == "part="* ]]; then
	PART="/dev/${1#part=}"
	shift
	
	echo "Using $PART as partition"
fi

if [[ "$1" == "mount="* ]]; then
	MOUNT="${1#mount=}"
	shift
	
	echo "Using $MOUNT as mount point"
fi

echo "Running make first..."
make all

echo "Writing MBR to $DEV"
dd if=boot/out/bin/mbr of="$DEV" bs=440 count=1

echo "Writing VBR to $PART"
dd if=boot/out/bin/vbr of="$PART" bs=512 count=1

echo "Writing BOOT to $PART"
dd if=boot/out/bin/boot of="$PART" bs=512 seek=2

echo "Making new JGFS on $PART"
../jgfs/bin/mkjgfs "$PART" || exit 1

echo "Mounting JGFS to $MOUNT"
mkdir -p "$MOUNT"
umount "$MOUNT"
../jgfs/bin/jgfs "$PART" "$MOUNT" &
sleep 1

echo "Copying KERN to JGFS"
cp kern/out/kern.bin "$MOUNT/kern"
sleep 1

echo "Unmounting JGFS"
killall -TERM jgfs

if [[ "$1" == "eject" ]]; then
	echo "Ejecting device"
	eject "$DEV"
fi

if [[ "$1" == "bochs" ]]; then
	echo "Running bochs"
	bochs
fi

exit 0
