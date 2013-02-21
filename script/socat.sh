#!/bin/sh

sudo socat PTY,link=/dev/ttyBochs0,mode=0666,raw,crtscts=1,b115200 PTY,link=/dev/ttyBochs1,mode=666,raw,crtscts=1,b115200
