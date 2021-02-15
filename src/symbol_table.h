#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

static FILE *identifier_file;
struct symbol_table_rec {
  const char *name;
  int type;
  struct ast *data;
  struct symbol_table_rec *next;
};

static struct symbol_table_rec *symbol_table_head;


struct symbol_table_rec *create_symbol_rec(const char *name, struct ast *value);
void insert_to_symbol_table(struct symbol_table_rec *new_node);
struct symbol_table_rec *search_symbol(const char *name);
#endif