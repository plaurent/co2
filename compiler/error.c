#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>

#include "error.h"

int errors = 0;
int warnings = 0;

static int write_error_message (const struct Token *token, const char *msg, va_list *app) {
	int result = 0;
	if (token) {
		result += fprintf (stderr, "%d: ", token->line);
	}
	result += vfprintf (stderr, msg, *app);
	return result;
}

int error (const struct Token *token, const char *msg, ...) {
	int result;
	va_list ap;
	errors ++;
 	va_start (ap, msg);
	result = write_error_message (token, msg, &ap);
	va_end (ap);
	return result;
}

int warning (const struct Token *token, const char *msg, ...) {
	int result;
	va_list ap;
	warnings ++;
 	va_start (ap, msg);
	result = write_error_message (token, msg, &ap);
	va_end (ap);
	return result;
}