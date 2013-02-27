#!/bin/sh
# justix
# (c) 2013 Justin Gottula
# The source code of this project is distributed under the terms of the
# simplified BSD license. See the LICENSE file for details.

# this script already ensures only a single instance
test/socat.sh &

minicom -D /dev/ttyBochs1
