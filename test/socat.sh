#!/bin/sh
# justix
# (c) 2013 Justin Gottula
# The source code of this project is distributed under the terms of the
# simplified BSD license. See the LICENSE file for details.


(
	if ! flock -n 3; then
		echo "$0: already running" >&2
		exit 1
	fi
	
	sudo socat PTY,link=/dev/ttyBochs0,mode=0666,raw,crtscts=1,b115200 \
		PTY,link=/dev/ttyBochs1,mode=666,raw,crtscts=1,b115200
) 3>/tmp/justix_socat.lock
