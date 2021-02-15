#include "helpers.h"
#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *boolean_to_string(int boolean)
{
  if (boolean)
  {
    return true_string;
  }
  else
  {
    return false_string;
  }
}

char *int_to_string(int value)
{
  char *str = (char *)malloc(sizeof(char) * 25);
  sprintf(str, "%d", value);
  return str;
}

char *float_to_string(double value)
{
  char *str = (char *)malloc(sizeof(char) * 25);
  sprintf(str, "%#f", value);
  return str;
}

char *read_string()
{
  size_t bufsize = 100;
  char *buffer = (char *)malloc(bufsize * sizeof(char));
  size_t characters = getline(&buffer, &bufsize, stdin);
  buffer = (char *)realloc(buffer, characters);
  return buffer;
}

char *stringify(struct ast *tree)
{
  if (tree == NULL)
    return null_string;

  switch (tree->nodeType)
  {
  case D_INTEGER:
    return int_to_string(((struct d_integer *)tree)->value);
  case D_DOUBLE:
    return float_to_string(((struct d_double *)tree)->value);
  case D_BOOL:
    return boolean_to_string(((struct d_integer *)tree)->value);
  default:
    return strdup(null_string);
  }
}

char *get_query_string()
{
  char *str = getenv("QUERY_STRING");
  if (str != NULL)
    return str;
  else
    return strdup("null");
}
