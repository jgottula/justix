#!/bin/sh

# this script already ensures only a single instance
test/socat.sh &

minicom -D /dev/ttyBochs1
