#include <argp.h>
#include <err.h>
#include "common.h"


struct {
	bool setup;
} param =
{
	.setup = false,
};


error_t parse_opt(int key, char *arg, struct argp_state *state) {
	switch (key) {
	case 's':
		param.setup = true;
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
static const char doc[] = "Run a test of jgsys.";
static const char args_doc[] = "";
static struct argp_option options[] = {
	{ NULL, 0, NULL, 0, "options:", 1 },
	{ "setup", 's', NULL, 0,
		"run setup first  [off by default]", 1 },
	
	{ 0 }
};
static struct argp argp =
	{ options, &parse_opt, args_doc, doc, NULL, NULL, NULL };


int main(int argc, char **argv) {
	argp_parse(&argp, argc, argv, 0, NULL, NULL);
	
	if (param.setup) {
		warnx("running setup first...");
		run(RF_FATAL, "script/bin/setup");
	}
	
	warnx("running install...");
	run(RF_FATAL, "script/bin/install");
	
	warnx("running bochs...");
	run_nofork(0, "bochs");
	
	return 0;
}
