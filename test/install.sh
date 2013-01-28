#!/bin/sh

usage() {
  echo "usage: $0 [disk] [part] [mount]"
  exit 1
}

if [[ "$1" == "" ]]; then
  usage
fi

if [[ "$2" == "" ]]; then
  usage
fi

if [[ "$3" == "" ]]; then
  usage
fi

echo "Running make first..."
make all

echo "Writing MBR to $1"
dd if=boot/out/bin/mbr of="$1" bs=440 count=1

echo "Writing VBR to $2"
dd if=boot/out/bin/vbr of="$2" bs=512 count=1

echo "Writing BOOT to $2"
dd if=boot/out/bin/boot of="$2" bs=512 seek=2

echo "Making new JGFS on $2"
../jgfs/bin/mkjgfs "$2" || exit 1

echo "Mounting JGFS to $3"
sudo umount /mnt/0
../jgfs/bin/jgfs "$2" "$3" &
sleep 1

echo "Copying KERN to JGFS"
cp kern/out/kern.bin "$3/kern"
sleep 1

echo "Unmounting JGFS"
killall -TERM jgfs

echo "Ejecting device"
eject "$1"

exit 0
