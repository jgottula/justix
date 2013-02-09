#include <assert.h>
#include <err.h>
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include "common.h"


void run(unsigned int flag, const char *cmdline, ...) {
	char buffer[4096];
	
	va_list ap;
	va_start(ap, cmdline);
	vsnprintf(buffer, sizeof(buffer), cmdline, ap);
	va_end(ap);
	
	size_t num_args = 0;
	char **args = malloc(128 * sizeof(char *));
	char *strtok_save = NULL;
	
	if (flag & RF_SUDO) {
		args[0] = strdup("sudo");
		++num_args;
	}
	
	char *arg = strtok_r(buffer, " ", &strtok_save);
	assert(arg != NULL);
	do {
		if ((num_args % 128) == 0) {
			args = realloc(args, (num_args + 128) * sizeof(char *));
		}
		
		args[num_args++] = strdup(arg);
		
		arg = strtok_r(NULL, " ", &strtok_save);
	} while (arg != NULL);
	
	char *prog = (flag & RF_SUDO) ? args[1] : args[0];
	
	if (!(flag & RF_NOECHO)) {
		fprintf(stderr, "\x1b[%s;1m>> \x1b[0m",
			((flag & RF_SUDO) ? "33" : "37"));
		
		for (size_t i = 0; i < num_args; ++i) {
			if (i != 0) {
				fputc(' ', stderr);
			}
			
			fputs(args[i], stderr);
		}
		
		fputc('\n', stderr);
	}
	
	int shmid;
	if ((shmid = shmget(IPC_PRIVATE, sizeof(int),
		IPC_CREAT | S_IRUSR | S_IWUSR)) == -1) {
		err(1, "shmget failed");
	}
	
	int *status = shmat(shmid, NULL, 0);
	if (status == (void *)-1) {
		err(1, "shmat failed");
	}
	
	*status = 0;
	
	pid_t pid;
	if ((pid = fork()) == 0) {
		/* child */
		
		if (flag & RF_QUIET) {
			fclose(stdout);
			fclose(stderr);
		}
		
		if (num_args % 128 == 0) {
			args = realloc(args, (num_args + 1) * sizeof(char *));
		}
		args[num_args] = NULL;
		
		if (execvpe(args[0], args, environ) == -1) {
			*status = errno;
			exit(0);
		}
	} else {
		/* parent */
		
		siginfo_t siginfo;
		if (waitid(P_PID, pid, &siginfo, WEXITED)  == -1) {
			err(1, "waitpid filed");
		}
		
		if (*status != 0) {
			errno = *status;
			err(1, "execvpe on '%s' failed", prog);
		}
		
		if (flag & RF_FATAL) {
			if (siginfo.si_code == CLD_EXITED) {
				if (siginfo.si_status != 0) {
					errx(1, "command '%s' exited with error code %d",
						prog, siginfo.si_status);
				}
			} else if (siginfo.si_code == CLD_KILLED ||
				siginfo.si_code == CLD_DUMPED) {
				errx(1, "command '%s' was killed with %s",
					prog, strsignal(siginfo.si_status));
			}
		}
	}
	
	if (shmdt(status) == -1) {
		err(1, "shmdt failed");
	}
	
	while (num_args-- > 0) {
		free(args[num_args]);
	}
	free(args);
}
