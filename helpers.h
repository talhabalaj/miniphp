#include <string.h>
#include <stdio.h>
#include <stdlib.h>

char true_string[5] = "true";
char false_string[6] = "false";

char* boolean_to_string(int boolean) {
  if (boolean) {
    return true_string;
  } else {
    return false_string;
  }
}

char* int_to_string(int value) {
  char* str = (char*)malloc(sizeof(char)*25);
  sprintf(str, "%d", value);
  return str;
}

char *float_to_string(int value) {
  char *str = (char *)malloc(sizeof(char) * 25);
  sprintf(str, "%#f", value);
  return str;
}
