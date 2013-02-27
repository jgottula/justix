#!/bin/sh
# justix
# (c) 2013 Justin Gottula
# The source code of this project is distributed under the terms of the
# simplified BSD license. See the LICENSE file for details.


usage() {
  echo "usage: $0 [16|32]"
  exit 1
}

if [[ "$1" == "" ]]; then
	usage
fi

SOURCE=$(mktemp)

echo "bits $1" >$SOURCE

echo "enter source below (EOF when done):"
cat >>$SOURCE

nasm -fbin -Ox -Wall -o/dev/stdout $SOURCE | ndisasm -a -b$1 /dev/stdin

rm -f $SOURCE
