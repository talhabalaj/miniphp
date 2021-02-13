#include <stdlib.h>
#include <string.h>

#define FUNCTION_VALUE 0
#define FLOAT_VALUE 1
#define STRING_VALUE 2
#define INT_VALUE 3
#define BOOL_VALUE 4

struct symbol_table_rec {
  const char* name;
  int type;
  union data
  {
    float floatVal;
    char* stringVal;
    int boolVal;
    int intVal;
    void (*fun)();
  } data;
  struct symbol_table_rec* next;
};

struct symbol_table_rec *create(const char *name, int symbol_data_type,
                               void *value) {
  struct symbol_table_rec *rec =
      (struct symbol_table_rec *)malloc(sizeof(struct symbol_table_rec));
  rec->name = name;
  rec->type = symbol_data_type;
  if (symbol_data_type == FLOAT_VALUE)
    rec->data.floatVal = *(float*)value;
  else if (symbol_data_type == STRING_VALUE)
    rec->data.stringVal = (char*)value;
  else if (symbol_data_type == FUNCTION_VALUE)
    rec->data.fun = (void (*)())value;
  else if (symbol_data_type == BOOL_VALUE)
    rec->data.boolVal = *(int*)value;
  else if (symbol_data_type == INT_VALUE)
    rec->data.intVal = *(int *)value;
  rec->next = 0;
  return rec;
}

void insert_to_symbol_table(struct symbol_table_rec **head,
                            struct symbol_table_rec *new_node) {
  if (head == NULL || *head == NULL) {
    *head = new_node;
    return;
  }

  struct symbol_table_rec *tmp = *head;
  while (tmp != NULL && tmp->next != 0) {
    tmp = tmp->next;
  }
  tmp->next = new_node;
}

struct symbol_table_rec *search_symbol(struct symbol_table_rec *head,
                                       const char *name) {
  struct symbol_table_rec *tmp = head;
  while (tmp) {
    if (strcmp(tmp->name, name) == 0)
      return tmp;
    tmp = tmp->next;
  }
  return 0;
}
