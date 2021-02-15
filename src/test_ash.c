#include <stdio.h>
#include "ast.h"

int main()
{
  for (int i = E_LT; i <= 20; i++)
  {
    struct ast *r = eval(create_ast(i, new_double(5), new_double(6)));
    if (r->nodeType == D_INTEGER)
    {
      printf("result: %d\n", ((struct d_integer *)r)->value);
    }
    else if (r->nodeType == D_DOUBLE)
    {
      printf("result: %f\n", ((struct d_double *)r)->value);
    } else {

      printf("result: %d\n", ((struct d_bool *)r)->value);
    }
  }
}