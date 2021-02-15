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

struct ast
{
  int nodeType;
  struct ast *left;
  struct ast *right;
};

struct d_integer
{
  int nodetype;
  int value;
};

struct d_bool
{
  int nodetype;
  short value;
};

struct d_double
{
  int nodetype;
  double value;
};

struct d_string
{
  int nodetype;
  char *value;
};

struct flow
{
  int nodetype;
  struct ast *condition;
  struct ast *if_true;
  struct ast *if_false;
};

struct ast *op(int optype, struct ast *a, struct ast *b);
struct ast *create_ast(int nodetype, struct ast *left, struct ast *right);
struct ast *new_integer(int value);
struct ast *new_string(char *value);
struct ast *new_bool(int value);
struct ast *new_double(double value);
struct ast *new_flow(int nodetype, struct ast *cond, struct ast *if_true, struct ast *if_false);
struct ast *get_symbol(const char *symbol_name);
struct ast *new_symbol(const char *symbol_name, struct ast *value);
struct ast *eval(struct ast *tree);
double perform_op(int optype, double a, double b);

#endif