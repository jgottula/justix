#ifndef JGSYS_SCRIPT_COMMON_H
#define JGSYS_SCRIPT_COMMON_H


enum run_flag {
	RF_NOECHO = (1 << 0),
	RF_SUDO   = (1 << 1),
	RF_FATAL  = (1 << 2),
	RF_QUIET  = (1 << 3),
};


void run(unsigned int flag, const char *cmdline, ...);


#endif
