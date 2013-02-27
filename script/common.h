/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details. */


#ifndef JUSTIX_SCRIPT_COMMON_H
#define JUSTIX_SCRIPT_COMMON_H


enum run_flag {
	RF_NOECHO = (1 << 0),
	RF_SUDO   = (1 << 1),
	RF_FATAL  = (1 << 2),
	RF_QUIET  = (1 << 3),
};


void run(unsigned int flag, const char *cmdline, ...);
void run_nofork(unsigned int flag, const char *cmdline, ...);


#endif
