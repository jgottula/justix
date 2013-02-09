#include <argp.h>
#include <bsd/string.h>
#include <err.h>
#include <inttypes.h>
#include <sys/stat.h>
#include <unistd.h>
#include "common.h"


struct {
	const char *image_file;
	const char *loop_dev;
	
	uint64_t image_size;
	uint32_t part_start;
} param =
{
	.image_file   = "test/zip100.img",
	.loop_dev     = "/dev/loop0",
	
	.image_size   = 196608 * 512,
	.part_start   = 32,
};


error_t parse_opt(int key, char *arg, struct argp_state *state) {
	switch (key) {
	case 'I':
		param.image_file = strdup(arg);
		break;
	case 'D':
		param.loop_dev = strdup(arg);
		break;
	case 's':
		switch (sscanf(arg, "%" SCNu64, &param.image_size)) {
		case EOF:
			warnx("image size: can't read that!");
			argp_usage(state);
		case 1:
			break;
		}
		break;
	case 'p':
		switch (sscanf(arg, "%" SCNu32, &param.part_start)) {
		case EOF:
			warnx("partition start sector: can't read that!");
			argp_usage(state);
		case 1:
			break;
		}
		break;
	case ARGP_KEY_ARG:
		warnx("excess argument(s)");
		argp_usage(state);
		break;
	case ARGP_KEY_END:
		break;
	default:
		return ARGP_ERR_UNKNOWN;
	}
	
	return 0;
}


/* argp structures */
static const char doc[] = "Set up a loop device for jgsys testing.";
static const char args_doc[] = "";
static struct argp_option options[] = {
	{ NULL, 0, NULL, 0, "string parameters:", 1 },
	{ "image", 'I', "FILE", 0,
		"image file             [default: test/zip100.img]", 1 },
	{ "dev", 'D', "DEVICE", 0,
		"loop device            [default: /dev/loop0]", 1 },
	
	{ NULL, 0, NULL, 0, "size parameters:", 2 },
	{ "size", 's', "NUMBER", 0,
		"image size in bytes    [default: 100663296]", 2, },
	{ "psect", 'p', "NUMBER", 0,
		"partition start sector [default: 32]", 2, },
	
	{ 0 }
};
static struct argp argp =
	{ options, &parse_opt, args_doc, doc, NULL, NULL, NULL };


int main(int argc, char **argv) {
	argp_parse(&argp, argc, argv, 0, NULL, NULL);
	
	warnx("image file:  %s", param.image_file);
	warnx("loop device: %s", param.loop_dev);
	warnx("image size:  %" PRIu64, param.image_size);
	warnx("part start:  %" PRIu32, param.part_start);
	
	warnx("cleaning up...");
	run(RF_QUIET, "killall -q jgfs");
	run(RF_SUDO | RF_FATAL, "modprobe loop");
	run(RF_SUDO | RF_QUIET, "losetup -d %s", param.loop_dev);
	(void)unlink(param.image_file);
	
	warnx("creating image file...");
	if (mknod(param.image_file, 0644, 0) == -1) {
		err(1, "mknod on '%s' failed", param.image_file);
	}
	if (truncate(param.image_file, param.image_size) == -1) {
		err(1, "truncate on '%s' failed", param.image_file);
	}
	
	warnx("making partition table...");
	run(RF_FATAL, "parted -s -a minimal -- %s mklabel msdos "
		"mkpart primary ext2 %" PRIu32 "s -1s set 1 boot on",
		param.image_file, param.part_start);
	
	warnx("setting up loop device...");
	run(RF_SUDO | RF_FATAL, "losetup -P %s %s",
		param.loop_dev, param.image_file);
	
	warnx("success");
	return 0;
}
