#include "ast.h"
#include "symbol_table.h"
#include <string.h>

struct ast *create_ast(int nodetype, struct ast *left, struct ast *right)
{
  struct ast *node = (struct ast *)malloc(sizeof(struct ast));
  node->nodeType = nodetype;
  node->left = left;
  node->right = right;
  return node;
}

struct ast *new_integer(int value)
{
  struct d_integer *node = (struct d_integer *)malloc(sizeof(struct d_integer));
  node->nodetype = D_INTEGER;
  node->value = value;

  return (struct ast *)node;
}

struct ast *new_string(char *value)
{
  struct d_string *node = (struct d_string *)malloc(sizeof(struct d_string));
  node->nodetype = D_STRING;
  node->value = strdup(value);

  return (struct ast *)node;
}

struct ast *new_bool(int value)
{
  struct d_integer *node = (struct d_integer *)malloc(sizeof(struct d_integer));
  node->nodetype = D_BOOL;
  node->value = !!value;

  return (struct ast *)node;
}

struct ast *new_double(double value)
{
  struct d_double *node = (struct d_double *)malloc(sizeof(struct d_double));
  node->nodetype = D_DOUBLE;
  node->value = value;

  return (struct ast *)node;
}

struct ast *new_flow(int nodetype, struct ast *cond, struct ast *if_true,
                     struct ast *if_false)
{
  struct flow *node = (struct flow *)malloc(sizeof(struct flow));
  node->condition = cond;
  node->if_false = if_false;
  node->if_true = if_true;
  return (struct ast *)node;
}

struct ast *get_symbol(const char *symbol_name)
{
  struct symbol_rec_table *symbol_rec = search_symbol(symbol_table_head, symbol_name);

  if (symbol_rec)
  {
   // return symbol_rec->data;
  }

  return 0;
}

struct ast *new_symbol(const char *symbol_name, struct ast *value)
{
  struct symbol_rec_table *symbol_rec = search_symbol(symbol_table_head, symbol_name);

  if (symbol_rec)
  {
  }
  else
  {
    // symbol_rec_table = create_symbol_rec(symbol_name, value);
    // node->nodetype = SYMBOL;
    // insert_to_symbol_table(node->rec);
  }

  // return (struct ast *)node;
}

struct ast *eval(struct ast *tree)
{
 if (tree == NULL)
    return NULL;

  switch (tree->nodeType)
  {
  case D_INTEGER:
  case D_DOUBLE:
  case D_STRING:
    printf("Getting value at %p\n", tree);
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
  case E_NE:
  {
    struct ast *left = eval(tree->left),
               *right = eval(tree->right);
    return op(tree->nodeType, left, right);
  }
  case S_ASSIGN:
  {

    struct ast *left = eval(tree->left),
               *right = eval(tree->right);
    char *name = ((struct d_string *)left)->value;
    printf("This is assignment of %s with %p\n", name, right);
    return new_symbol(name, right);
  }

  case SYMBOL:
  {

    struct ast *left = eval(tree->left);
    char *name = ((struct d_string *)left)->value;
    struct symbol *rec = (struct symbol *)get_symbol(name);

    printf("Getting symbol name %s at %p\n", name, left);
    if (rec)
    {
      //return rec->rec;make
    }
    else
    {
      printf("Symbol Not Found\n");
      return 0;
    }
  }

  case S_ECHO:
  {
    struct ast *left = eval(tree->left);
    printf("%s", stringify(left));
    return 0;
  }

  default:
    break;
  }
}

struct ast *op(int optype, struct ast *a, struct ast *b)
{
  if (!a || !b)
    return 0;

  struct ast *result;

  if (a->nodeType == D_DOUBLE)
  {
    double a_double = ((struct d_double *)a)->value;

    if (b->nodeType == D_DOUBLE)
    {
      double b_double = ((struct d_double *)b)->value;
      result = new_double(perform_op(optype, a_double, b_double));
    }
    else if (b->nodeType == D_INTEGER)
    {
      int b_int = ((struct d_integer *)b)->value;
      result = new_double(perform_op(optype, a_double, (double)b_int));
    }
  }
  else if (a->nodeType == D_INTEGER)
  {
    double a_int = ((struct d_integer *)a)->value;

    if (b->nodeType == D_DOUBLE)
    {
      double b_double = ((struct d_double *)b)->value;
      result = new_double(perform_op(optype, a_int, b_double));
    }
    else if (b->nodeType == D_INTEGER)
    {
      int b_int = ((struct d_integer *)b)->value;
      double ans = perform_op(optype, a_int, (double)b_int);
      if (ans - (int)ans == 0)
        result = new_integer((int)ans);
      else
        result = new_double(ans);
    }
  }

  if (optype >= 15 && optype <= 22)
  {
    if (result->nodeType == D_INTEGER)
    {
      int v = ((struct d_integer *)result)->value;
      free(result);
      result = new_bool(v);
    }
    else
    {
      int v = ((struct d_double *)result)->value;
      free(result);
      result = new_bool(v);
    }
  }

  return result;
}

double perform_op(int optype, double a, double b)
{
  switch (optype)
  {
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
