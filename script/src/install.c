#include <argp.h>
#include <bsd/string.h>
#include <err.h>
#include <fcntl.h>
#include <libudev.h>
#include <mntent.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/shm.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
#include "common.h"


#define FUSE_PATH "../jgfs/bin/jgfs"
#define MKFS_PATH "../jgfs/bin/mkjgfs"

#define MBR_PATH    "boot/out/bin/mbr"
#define STAGE1_PATH "boot/out/bin/stage1"
#define STAGE2_PATH "boot/out/bin/stage2"
#define KERN_PATH   "kern/out/kern.bin"

#define MBR_SIZE    440
#define STAGE1_SIZE 512


struct {
	const char *part_path;
	const char *dev_path;
	
	bool nomake;
	bool floppy;
	bool eject;
} param =
{
	.part_path = "/dev/loop0p1",
	.dev_path  = NULL,
	
	.nomake = false,
	.floppy = false,
	.eject  = false,
};


const char *prepend_dev(const char *orig) {
	char *new = malloc(strlen(orig) + 6);
	
	strcpy(new, "/dev/");
	strcat(new, orig);
	
	return new;
}

const char *process_dev_path(const char *orig) {
	/* follow symlinks and add leading /dev/ component if missing */
	if (strstr(orig, "/dev/") == orig) {
		char *canonical = canonicalize_file_name(orig);
		if (canonical == NULL) {
			err(1, "canonicalize_file_name failed");
		} else if (strlen(canonical) <= 5) {
			errx(1, "bad path: '%s'", canonical);
		}
		
		return canonical;
	} else {
		return process_dev_path(prepend_dev(orig));
	}
}

error_t parse_opt(int key, char *arg, struct argp_state *state) {
	switch (key) {
	case 'n':
		param.nomake = true;
		break;
	case 'e':
		param.eject = true;
		break;
	case ARGP_KEY_ARG:
		if (state->arg_num == 0) {
			param.part_path = process_dev_path(arg);
		} else if (state->arg_num == 1) {
			param.dev_path = process_dev_path(arg);
		} else {
			warnx("excess argument(s)");
			argp_usage(state);
		}
		break;
	case ARGP_KEY_END:
		break;
	default:
		return ARGP_ERR_UNKNOWN;
	}
	
	return 0;
}


/* argp structures */
static const char doc[] = "Install jgsys to a device partition for testing.";
static const char args_doc[] = "[PARTITION] [DEVICE]";
static struct argp_option options[] = {
	{ NULL, 0, NULL, 0, "Device names may be symlinks or omit /dev.", 1 },
	{ NULL, 0, NULL, 0, "PARTITION defaults to /dev/loop0p1;\n"
		"DEVICE is automatically detected unless specified.", 1 },
	
	{ NULL, 0, NULL, 0, "options:", 2 },
	{ "no-make", 'n', NULL, 0,
		"don't run make first        [off by default]", 2 },
	{ "eject", 'e', NULL, 0,
		"eject device if successful  [off by default]", 2 },
	{ "floppy", 'f', NULL, 0,
		"floppy mode (no mbr)        [off by default]", 2 },
	
	{ 0 }
};
static struct argp argp =
	{ options, &parse_opt, args_doc, doc, NULL, NULL, NULL };


bool find_part_parent(void) {
	bool found = false;
	int status;
	
	struct udev *udev;
	if ((udev = udev_new()) == NULL) {
		errx(1, "udev_new returned NULL");
	}
	
	struct udev_enumerate *enumerate;
	if ((enumerate = udev_enumerate_new(udev)) == NULL) {
		errx(1, "udev_enumerate_new returned NULL");
	}
	
	if ((status = udev_enumerate_scan_devices(enumerate)) != 0) {
		errno = -status;
		err(1, "udev_enumerate_scan_devices failed");
	}
	
	struct udev_list_entry *all_devices, *entry;
	all_devices = udev_enumerate_get_list_entry(enumerate);
	
	udev_list_entry_foreach(entry, all_devices) {
		const char *syspath = udev_list_entry_get_name(entry);
		
		struct udev_device *device;
		if ((device = udev_device_new_from_syspath(udev, syspath)) == NULL) {
			errx(1, "udev_device_new_from_syspath returned NULL");
		}
		
		const char *sysname = udev_device_get_sysname(device);
		if (strcmp(sysname, param.part_path + 5) == 0) {
			struct udev_device *parent;
			if ((parent = udev_device_get_parent(device)) != NULL) {
				const char *parent_sysname = udev_device_get_sysname(parent);
				if (parent_sysname == NULL) {
					errx(1, "parent device name is NULL");
				}
				
				param.dev_path = prepend_dev(parent_sysname);
				
				found = true;
			}
		}
		
		if (udev_device_unref(device) != NULL) {
			errx(1, "udev_device_unref did not return NULL");
		}
		
		if (found) {
			break;
		}
	}
	
	if (udev_enumerate_unref(enumerate) != NULL) {
		errx(1, "udev_enumerate_unref did not return NULL");
	}
	
	if (udev_unref(udev) != NULL) {
		errx(1, "udev_unref did not return NULL");
	}
	
	return found;
}

void block_copy(int dest_fd, const char *dest_path, const char *src_path,
	off64_t off, ssize_t size) {
	
	int src_fd = -1;
	if ((src_fd = open(src_path, O_RDONLY)) == -1) {
		err(1, "could not open '%s'", src_path);
	}
	
	if (size == 0) {
		struct stat src_stat;
		if (fstat(src_fd, &src_stat) == -1) {
			err(1, "could not stat '%s'", src_path);
		}
		
		size = src_stat.st_size;
	}
	
	uint8_t *data = malloc(size);
	
	ssize_t b_read = read(src_fd, data, size);
	if (b_read == -1) {
		err(1, "could not read from '%s'", src_path);
	} else if (b_read != size) {
		err(1, "incomplete read (%zd/%zd bytes) from '%s'",
			b_read, size, src_path);
	}
	
	if (close(src_fd) == -1) {
		err(1, "could not close '%s'", src_path);
	}
	
	off64_t off_actual = lseek64(dest_fd, off, SEEK_SET);
	if (off_actual == -1) {
		err(1, "lseek64 on '%s' failed", dest_path);
	} else if (off_actual != off) {
		errx(1, "could not seek to desired offset of '%s'", dest_path);
	}
	
	ssize_t b_written = write(dest_fd, data, size);
	if (b_written == -1) {
		err(1, "could not write to '%s'", dest_path);
	} else if (b_written != size) {
		err(1, "incomplete write (%zd/%zd bytes) to '%s'",
			b_written, size, dest_path);
	}
	
	free(data);
}

void file_copy(const char *dest_path, const char *src_path) {
	int src_fd = -1;
	if ((src_fd = open(src_path, O_RDONLY)) == -1) {
		err(1, "could not open '%s'", src_path);
	}
	
	int dest_fd = -1;
	if ((dest_fd = creat(dest_path, 0644)) == -1) {
		err(1, "could not create '%s'", dest_path);
	}
	
	struct stat src_stat;
	if (fstat(src_fd, &src_stat) == -1) {
		err(1, "could not stat '%s'", src_path);
	}
	
	off_t size = src_stat.st_size;
	uint8_t *data = malloc(size);
	
	ssize_t b_read = read(src_fd, data, size);
	if (b_read == -1) {
		err(1, "could not read from '%s'", src_path);
	} else if (b_read != size) {
		err(1, "incomplete read (%zd/%zd bytes) from '%s'",
			b_read, size, src_path);
	}
	
	ssize_t b_written = write(dest_fd, data, size);
	if (b_written == -1) {
		err(1, "could not write to '%s'", dest_path);
	} else if (b_written != size) {
		err(1, "incomplete write (%zd/%zd bytes) to '%s'",
			b_written, size, dest_path);
	}
	
	free(data);
	
	if (close(src_fd) == -1) {
		err(1, "could not close '%s'", src_path);
	}
	
	if (close(dest_fd) == -1) {
		err(1, "could not close '%s'", dest_path);
	}
}

void handle_sigchld(int signum) {
	if (signum == SIGCHLD) {
		errx(1, "child process died unexpectedly");
	} else {
		errx(1, "wrong signal (%d) in handle_sigchild", signum);
	}
}

bool check_jgfs_mount(const char *mount_dir) {
	FILE *mtab = setmntent("/etc/mtab", "r");
	if (mtab == NULL) {
		err(1, "could not open /etc/mtab");
	}
	
	struct mntent *ent;
	while ((ent = getmntent(mtab)) != NULL) {
		if (strcmp(ent->mnt_type, "fuse.jgfs") == 0 &&
			strcmp(ent->mnt_dir, mount_dir) == 0) {
			return true;
		}
	}
	
	endmntent(mtab);
	
	return false;
}

void install_kern(void) {
	char *mount_dir;
	if ((mount_dir = tempnam(NULL, "jgsys")) == NULL) {
		errx(1, "could not generate a temporary mount dir name");
	}
	
	if (mkdir(mount_dir, 0755) == -1) {
		err(1, "mkdir failed on '%s'", mount_dir);
	}
	
	warnx("mounting jgfs on '%s'", mount_dir);
	
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
	
	signal(SIGCHLD, handle_sigchld);
	
	pid_t pid;
	if ((pid = fork()) == 0) {
		/* child */
		
		if (execlp(FUSE_PATH, FUSE_PATH,
			param.part_path, mount_dir, (char *)NULL) == -1) {
			*status = errno;
			exit(0);
		}
	} else {
		/* parent */
		
		bool mounted = false;
		do {
			if (nanosleep(&(struct timespec){ .tv_sec = 0, .tv_nsec = 10000000},
				NULL) == -1) {
				err(1, "nanosleep failed");
			}
			
			if (check_jgfs_mount(mount_dir)) {
				mounted = true;
			}
		} while (!mounted);
		
		warnx("mounted jgfs");
		
		char dest_path[PATH_MAX];
		snprintf(dest_path, sizeof(dest_path), "%s/kern", mount_dir);
		file_copy(dest_path, KERN_PATH);
		
		/* TODO: syncfs? */
		
		signal(SIGCHLD, SIG_DFL);
		
		run(0, "fusermount -u %s", mount_dir);
		
		siginfo_t siginfo;
		if (waitid(P_PID, pid, &siginfo, WEXITED)  == -1) {
			err(1, "waitpid failed");
		}
		
		if (*status != 0) {
			errno = *status;
			err(1, "execlp on '%s' failed", FUSE_PATH);
		}
		
		if (siginfo.si_code == CLD_EXITED) {
			if (siginfo.si_status != 0) {
				errx(1, "command '%s' exited with error code %d",
					FUSE_PATH, siginfo.si_status);
			}
		} else if (siginfo.si_code == CLD_KILLED ||
			siginfo.si_code == CLD_DUMPED) {
			errx(1, "command '%s' was killed with %s",
				FUSE_PATH, strsignal(siginfo.si_status));
		}
	}
	
	if (shmdt(status) == -1) {
		err(1, "shmdt failed");
	}
	
	if (rmdir(mount_dir) == -1) {
		err(1, "rmdir failed on '%s'", mount_dir);
	}
	free(mount_dir);
}

int main(int argc, char **argv) {
	argp_parse(&argp, argc, argv, 0, NULL, NULL);
	
	if (param.dev_path == NULL && !param.floppy) {
		if (!find_part_parent()) {
			errx(1, "could not find parent device of '%s'", param.part_path);
		}
	}
	
	warnx("partition: %s", param.part_path);
	warnx("device:    %s", param.dev_path);
	warnx("run make:  %s", (param.nomake ? "no" : "yes"));
	warnx("floppy     %s", (param.floppy ? "yes" : "no"));
	warnx("eject:     %s", (param.eject ? "yes" : "no"));
	
	if (!param.nomake) {
		warnx("running make first...");
		run(RF_FATAL, "make all");
	}
	
	if (access(param.part_path, F_OK) == -1) {
		err(1, "cannot access '%s'", param.part_path);
	} else if (access(param.dev_path, F_OK) == -1) {
		err(1, "cannot access '%s'", param.dev_path);
	}
	
	warnx("making new jgfs on '%s'", param.part_path);
	run(RF_SUDO | RF_FATAL, MKFS_PATH " -Z %s", param.part_path);
	
	int dev_fd  = -1;
	int part_fd = -1;
	
	if (!param.floppy) {
		if ((dev_fd = open(param.dev_path, O_RDWR)) == -1) {
			err(1, "could not open '%s'", param.dev_path);
		}
		
		warnx("writing mbr to '%s'", param.dev_path);
		block_copy(dev_fd, param.dev_path, MBR_PATH, 0, MBR_SIZE);
	}
	
	if ((part_fd = open(param.part_path, O_RDWR)) == -1) {
		err(1, "could not open '%s'", param.part_path);
	}
	
	warnx("writing stage1 to '%s'", param.part_path);
	block_copy(part_fd, param.part_path, STAGE1_PATH, 0, STAGE1_SIZE);
	
	warnx("writing stage2 to '%s'", param.part_path);
	block_copy(part_fd, param.part_path, STAGE2_PATH, 1024, 0);
	
	install_kern();
	
	if (param.eject) {
		if (param.floppy) {
			run(0, "eject %s", param.part_path);
		} else {
			run(0, "eject %s", param.dev_path);
		}
	}
	
	if (part_fd != -1) {
		if (close(part_fd) == -1) {
			err(1, "could not close '%s'", param.part_path);
		}
		part_fd = -1;
	}
	if (dev_fd != -1) {
		if (close(dev_fd) == -1) {
			err(1, "could not close '%s'", param.dev_path);
		}
		dev_fd = -1;
	}
	
	warnx("success");
	return 0;
}
