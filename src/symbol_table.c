#include "symbol_table.h"
#include "ast.h"
struct symbol_table_rec *
create_symbol_rec(const char *name, struct ast *value)
{
  if (!identifier_file)
    identifier_file = fopen("identifiers.txt", "w+");

  struct symbol_table_rec *rec =
      (struct symbol_table_rec *)malloc(sizeof(struct symbol_table_rec));

  rec->name = name;
  rec->data = value;
  rec->next = 0;

  if (identifier_file)
  {
    fprintf(identifier_file, "%s\n", name);
  }
  return rec;
}

void insert_to_symbol_table(struct symbol_table_rec** head, struct symbol_table_rec *new_node)
{
  if (head == NULL || *head == NULL)
  {
    *head = new_node;
    return;
  }

  struct symbol_table_rec *tmp = *head;
  while (tmp != NULL && tmp->next != 0)
  {
    tmp = tmp->next;
  }
  tmp->next = new_node;
}

struct symbol_table_rec *search_symbol(struct symbol_table_rec * head, const char *name)
{
  struct symbol_table_rec *tmp = head;
  while (tmp)
  {
    if (strcmp(tmp->name, name) == 0)
      return tmp;
    tmp = tmp->next;
  }
  return 0;
}
