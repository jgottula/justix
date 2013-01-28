#!/bin/sh

ZIP100_SECT=196608
ZIP250_SECT=489532

SIZE="$((ZIP100_SECT/2))K"
IMAGE="test/zip100.img"
LOOPDEV="/dev/loop0"

PART_START="32s"
PART_END="-0"

usage() {
  echo "usage: $0 [size=] [image=] [loopdev=] [loop]"
  exit 1
}

if [[ "$1" == "size="* ]]; then
	SIZE="${1#size=}"
	shift
	
	echo "Using $SIZE as size"
fi

if [[ "$1" == "image="* ]]; then
	IMAGE="${1#image=}"
	shift
	
	echo "Using $IMAGE as image"
fi

if [[ "$1" == "loopdev="* ]]; then
	loopdev="/dev/${1#loopdev=}"
	shift
	
	echo "Using $LOOPDEV as loopback device"
fi

modprobe loop

echo "Cleaning up first..."
killall -TERM jgfs
sudo losetup -d "$LOOPDEV"
rm "$IMAGE"

echo "Truncating $IMAGE to $SIZE"
truncate -s "$SIZE" "$IMAGE" || exit 1

echo "Creating partition table on $IMAGE"
parted -s -a minimal "$IMAGE" -- mklabel msdos \
	mkpart primary ext2 "$PART_START" "$PART_END" set 1 boot on

echo "Setting up $LOOPDEV as a loop device"
sudo losetup -P "$LOOPDEV" "$IMAGE"
