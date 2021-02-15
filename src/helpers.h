#include "ast.h"

#ifndef HELPERS_H
#define HELPERS_H

static char true_string[5] = "true";
static char null_string[5] = "null";
static char false_string[6] = "false";

char *boolean_to_string(int boolean);
char *int_to_string(int value);
char *float_to_string(double value);
char *read_string();
char *stringify(struct ast *tree);
char *get_query_string();

#endif