#!/bin/sh

# this script already ensures only a single instance
script/socat.sh &

minicom -D /dev/ttyBochs1
