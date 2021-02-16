#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef AST_H
#define AST_H

#define D_INTEGER 0
#define D_DOUBLE 1
#define D_BOOL 2
#define D_STRING 3
#define E_ADD 10
#define E_SUB 11
#define E_MUL 12
#define E_DIV 13
#define E_MOD 14
#define E_LT 15
#define E_GT 16
#define E_LE 17
#define E_GE 18
#define E_EE 19
#define E_NE 20
#define E_AND 21
#define E_OR 22
#define E_NOT 21
#define S_ASSIGN 30
#define S_ECHO 31
#define F_IF_STATMENT 50
#define F_WHILE_STATMENT 51
#define SYMBOL 60

static FILE *identifier_file;

struct ast {
  int nodeType;
  struct ast *left;
  struct ast *right;
};

struct ast_stack {
  struct ast_stack *prev;
  struct ast *data;
};

struct symbol_table_rec {
  const char *name;
  int type;
  struct ast *data;
  struct symbol_table_rec *next;
};

struct symbol_table_rec *symbol_table_head = NULL;
struct ast_stack *stack_head = NULL;

struct d_integer {
  int nodetype;
  int value;
};

struct d_bool {
  int nodetype;
  short value;
};

struct d_double {
  int nodetype;
  double value;
};

struct d_string {
  int nodetype;
  char *value;
};

struct flow {
  int nodetype;
  struct ast *condition;
  struct ast *if_true;
  struct ast *if_false;
};

static char true_string[5] = "true";
static char null_string[5] = "null";
static char false_string[6] = "false";

char *boolean_to_string(int boolean);
char *int_to_string(int value);
char *float_to_string(double value);
char *read_string();
char *stringify(struct ast *tree);
char *get_query_string();
struct ast *op(int optype, struct ast *a, struct ast *b);
struct ast *create_ast(int nodetype, struct ast *left, struct ast *right);
struct ast *new_integer(int value);
struct ast *new_string(char *value);
struct ast *new_bool(int value);
struct ast *new_double(double value);
struct ast *new_flow(int nodetype, struct ast *cond, struct ast *if_true,
                     struct ast *if_false);
struct ast *get_symbol(const char *symbol_name);
struct ast *new_symbol(const char *symbol_name, struct ast *value);
struct ast *eval(struct ast *tree);
double perform_op(int optype, double a, double b);
struct symbol_table_rec *create_symbol_rec(const char *name, struct ast *value);
void insert_to_symbol_table(struct symbol_table_rec *new_node);
struct symbol_table_rec *search_symbol(const char *name);
struct ast_stack *insert_to_stack(struct ast *value);
struct ast *pop_stack();

struct ast_stack *insert_to_stack(struct ast *value) {
  struct ast_stack *tmp = (struct ast_stack *)malloc(sizeof(struct ast_stack));
  tmp->data = value;
  if (!stack_head) {
    stack_head = tmp;
  } else {
    struct ast_stack *z = stack_head;
    stack_head = tmp;
    stack_head->prev = z;
  }
  return stack_head;
}

struct ast *pop_stack() {
  if (!stack_head) {
    return 0;
  }
  struct ast_stack *tmp = stack_head;
  stack_head = stack_head->prev;
  return tmp->data;
}

struct ast *create_ast(int nodetype, struct ast *left, struct ast *right) {
  struct ast *node = (struct ast *)malloc(sizeof(struct ast));
  node->nodeType = nodetype;
  node->left = left;
  node->right = right;
  return node;
}

struct ast *new_integer(int value) {
  struct d_integer *node = (struct d_integer *)malloc(sizeof(struct d_integer));
  node->nodetype = D_INTEGER;
  node->value = value;

  return (struct ast *)node;
}

struct ast *new_string(char *value) {
  struct d_string *node = (struct d_string *)malloc(sizeof(struct d_string));
  node->nodetype = D_STRING;
  node->value = strdup(value);

  return (struct ast *)node;
}

struct ast *new_bool(int value) {
  struct d_integer *node = (struct d_integer *)malloc(sizeof(struct d_integer));
  node->nodetype = D_BOOL;
  node->value = !!value;

  return (struct ast *)node;
}

struct ast *new_double(double value) {
  struct d_double *node = (struct d_double *)malloc(sizeof(struct d_double));
  node->nodetype = D_DOUBLE;
  node->value = value;

  return (struct ast *)node;
}

struct ast *new_flow(int nodetype, struct ast *cond, struct ast *if_true,
                     struct ast *if_false) {
  struct flow *node = (struct flow *)malloc(sizeof(struct flow));
  node->nodetype = nodetype;
  node->condition = cond;
  node->if_false = if_false;
  node->if_true = if_true;
  return (struct ast *)node;
}

struct ast *get_symbol(const char *symbol_name) {
  struct symbol_table_rec *r = search_symbol(symbol_name);

  if (r) {
    return (struct ast *)r->data;
  }

  return 0;
}

struct ast *new_symbol(const char *symbol_name, struct ast *value) {
  struct symbol_table_rec *symbol_rec = search_symbol(symbol_name);

  if (symbol_rec) {
    symbol_rec->type = value->nodeType;
    symbol_rec->data = value;
  } else {
    symbol_rec = create_symbol_rec(symbol_name, value);
    symbol_rec->type = value->nodeType;
    insert_to_symbol_table(symbol_rec);
  }

  return (struct ast *)symbol_rec;
}

struct ast *eval(struct ast *tree) {
  if (tree == NULL)
    return NULL;

  switch (tree->nodeType) {
  case D_INTEGER:
  case D_DOUBLE:
  case D_STRING:
  case D_BOOL:
    //printf("Getting value at %p\n", tree);
    return tree;

  case E_ADD:
  case E_DIV:
  case E_SUB:
  case E_MUL:
  case E_MOD:
  case E_LT:
  case E_LE:
  case E_GE:
  case E_GT:
  case E_EE:
  case E_NE: {
    struct ast *left = eval(tree->left), *right = eval(tree->right);
    return op(tree->nodeType, left, right);
  }
  case S_ASSIGN: {
    struct ast *left = eval(tree->left), *right = eval(tree->right);
    char *name = ((struct d_string *)left)->value;
    //printf("This is assignment of %s with %p\n", name, right);
    return new_symbol(name, right);
  }

  case F_IF_STATMENT: {
    //printf("Running if condition\n");
    struct flow *f = (struct flow *)tree;
    struct d_bool *cond = (struct d_bool *)eval(f->condition);
    if (cond->value) {
      return eval(f->if_true);
    }
    return eval(f->if_false);
  }

  case SYMBOL: {

    struct ast *left = eval(tree->left);
    char *name = ((struct d_string *)left)->value;
    struct ast *rec = get_symbol(name);

    // printf("Getting symbol name %s at %p\n", name, left);
    if (rec) {
      return rec;
    } else {
      printf("Symbol Not Found\n");
      return 0;
    }
  }

  case S_ECHO: {
    struct ast *left = eval(tree->left);
    printf("%s", stringify(left));
    return 0;
  }

  default:
    break;
  }
}

struct ast *op(int optype, struct ast *a, struct ast *b) {
  if (!a || !b)
    return 0;

  struct ast *result;

  if (a->nodeType == D_DOUBLE) {
    double a_double = ((struct d_double *)a)->value;

    if (b->nodeType == D_DOUBLE) {
      double b_double = ((struct d_double *)b)->value;
      result = new_double(perform_op(optype, a_double, b_double));
    } else if (b->nodeType == D_INTEGER) {
      int b_int = ((struct d_integer *)b)->value;
      result = new_double(perform_op(optype, a_double, (double)b_int));
    }
  } else if (a->nodeType == D_INTEGER) {
    double a_int = ((struct d_integer *)a)->value;

    if (b->nodeType == D_DOUBLE) {
      double b_double = ((struct d_double *)b)->value;
      result = new_double(perform_op(optype, a_int, b_double));
    } else if (b->nodeType == D_INTEGER) {
      int b_int = ((struct d_integer *)b)->value;
      double ans = perform_op(optype, a_int, (double)b_int);
      if (ans - (int)ans == 0)
        result = new_integer((int)ans);
      else
        result = new_double(ans);
    }
  }

  if (optype >= 15 && optype <= 22) {
    if (result->nodeType == D_INTEGER) {
      int v = ((struct d_integer *)result)->value;
      free(result);
      result = new_bool(v);
    } else {
      int v = ((struct d_double *)result)->value;
      free(result);
      result = new_bool(v);
    }
  }

  return result;
}

double perform_op(int optype, double a, double b) {
  switch (optype) {
  case E_ADD:
    return a + b;
  case E_SUB:
    return a - b;
  case E_DIV:
    return a / b;
  case E_MUL:
    return a * b;
  case E_MOD:
    return fmod(a, b);
  case E_LT:
    return a < b;
  case E_LE:
    return a <= b;
  case E_GE:
    return a >= b;
  case E_GT:
    return a > b;
  case E_EE:
    return a == b;
  case E_NE:
    return a != b;
  case E_AND:
    return a && b;
  case E_OR:
    return a || b;
  }
}
struct symbol_table_rec *create_symbol_rec(const char *name,
                                           struct ast *value) {
  if (!identifier_file)
    identifier_file = fopen("identifiers.txt", "w+");

  struct symbol_table_rec *rec =
      (struct symbol_table_rec *)malloc(sizeof(struct symbol_table_rec));

  rec->name = name;
  rec->data = value;
  rec->next = 0;

  if (identifier_file) {
    fprintf(identifier_file, "%s\n", name);
  }
  return rec;
}

void insert_to_symbol_table(struct symbol_table_rec *new_node) {

  if (!symbol_table_head) {
    symbol_table_head = new_node;
    return;
  }

  struct symbol_table_rec *tmp = symbol_table_head;
  while (tmp != NULL && tmp->next != 0) {
    tmp = tmp->next;
  }
  tmp->next = new_node;
}

struct symbol_table_rec *search_symbol(const char *name) {
  struct symbol_table_rec *tmp = symbol_table_head;
  while (tmp) {
    if (strcmp(tmp->name, name) == 0)
      return tmp;
    tmp = tmp->next;
  }
  return 0;
}

char *boolean_to_string(int boolean) {
  if (boolean) {
    return true_string;
  } else {
    return false_string;
  }
}

char *int_to_string(int value) {
  char *str = (char *)malloc(sizeof(char) * 25);
  sprintf(str, "%d", value);
  return str;
}

char *float_to_string(double value) {
  char *str = (char *)malloc(sizeof(char) * 25);
  sprintf(str, "%#f", value);
  return str;
}

char *read_string() {
  size_t bufsize = 100;
  char *buffer = (char *)malloc(bufsize * sizeof(char));
  size_t characters = getline(&buffer, &bufsize, stdin);
  buffer = (char *)realloc(buffer, characters);
  return buffer;
}

char *stringify(struct ast *tree) {
  char *null = strdup(null_string);
  if (tree == NULL)
    return null;

  switch (tree->nodeType) {
  case D_INTEGER:
    return int_to_string(((struct d_integer *)tree)->value);
  case D_DOUBLE:
    return float_to_string(((struct d_double *)tree)->value);
  case D_BOOL:
    return boolean_to_string(((struct d_integer *)tree)->value);
  case D_STRING:
    return ((struct d_string *)tree)->value;
  default:
    return null;
  }
}

char *get_query_string() {
  char *str = getenv("QUERY_STRING");
  if (str != NULL)
    return str;
  else
    return strdup("null");
}

#endif