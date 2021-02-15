#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

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

double perform_op(int optype, double a, double b);
struct ast *op(int optype, struct ast *a, struct ast *b);

struct ast {
  int nodeType;
  struct ast *left;
  struct ast *right;
};

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

struct symbol {
  int nodetype;
  struct symbol_table_rec *rec;
};

struct flow {
  int nodetype;
  struct ast *condition;
  struct ast *if_true;
  struct ast *if_false;
};

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
  node->condition = cond;
  node->if_false = if_false;
  node->if_true = if_true;
  return (struct ast *)node;
}

struct ast *get_symbol(const char *symbol_name) {
  struct symbol_rec_table *symbol_rec = search_symbol(symbol_name);

  if (symbol_rec) {
    struct symbol *node = (struct symbol *)malloc(sizeof(struct symbol));
    node->nodetype = SYMBOL;
    node->rec = symbol_rec;
    return (struct ast *)node;
  }

  return 0;
}

struct ast *new_symbol(const char *symbol_name, struct ast *value) {
  struct symbol_rec_table *symbol_rec = search_symbol(symbol_name);
  struct symbol *node = (struct symbol *)malloc(sizeof(struct symbol));

  if (symbol_rec) {
    node->nodetype = SYMBOL;
    node->rec = symbol_rec;
  } else {
    node->rec = create_symbol_rec(symbol_name, value);
    node->nodetype = SYMBOL;
    insert_to_symbol_table(node->rec);
  }

  return (struct ast *)node;
}

struct ast *eval(struct ast *tree) {
  if (tree == NULL)
    return NULL;

  struct ast *left, *right;
  if (tree->nodeType != D_BOOL && tree->nodeType != D_DOUBLE &&
      tree->nodeType != D_INTEGER) {
    printf("Eval at left: %p\n", tree->left);
    left = eval(tree->left);
    if (tree->nodeType != S_ASSIGN) {
      printf("Eval at right: %p\n", tree->right);
      right = eval(tree->right);
    }
  }

  switch (tree->nodeType) {
  case D_INTEGER:
  case D_DOUBLE:
  case D_STRING:
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
    return op(tree->nodeType, left, right);

  case S_ASSIGN: {
    char *name = ((struct d_string *)left)->value;
    struct symbol_table_rec *node = search_symbol(name);
    if (!node) {
      node = create_symbol_rec(name, right);
      insert_to_symbol_table(node);
    }
    return get_symbol(name);
  }

  case S_ECHO: {
    
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

#endif