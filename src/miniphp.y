%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include <ctype.h>
  #include "syntax_tree.h"

  void init();

  int yylex();
  void yyerror(const char*);
%}

%define parse.trace

%union {
  long double dtype;
  int boolean;
  int itype;
  char* string;
  struct ast* tree;
}

%token <string> STRING
%token <string> IDENTIFIER
%token <string> IDENTIFIER_NAME
%token <dtype> FLOAT
%token <itype> INTEGER
%token <boolean> TRUE FALSE
%token <string> OTHER
%token PHPSTART PHPEND ABSTRACT AND ARRAY AS BREAK CALLABLE CASE CATCH CLASS CLONE CONST CONTINUE DECLARE DEFAULT DIE DO ECHO_S ELSE ELSEIF EMPTY ENDDECLARE ENDFOR ENDFOREACH ENDIF ENDSWITCH ENDWHILE EVAL EXIT EXTENDS FINAL FINALLY FOR FOREACH FUNCTION GLOBAL GOTO IF IMPLEMENTS INCLUDE INCLUDE_ONCE INSTANCEOF INSTEADOF INTERFACE ISSET LIST NAMESPACE NEW OR PRINT PRIVATE PROTECTED PUBLIC REQUIRE REQUIRE_ONCE RETURN STATIC SWITCH THROW TRAIT TRY UNSET USE VAR WHILE XOR LE
GE EE NE

%left '.'
%right ';'
%left AND OR
%left '<' '>' '=' NE LE GE
%left '+' '-'
%left '*' '/'
%left '%'
%left '(' ')'
%left '!'

%type<tree> Expr PrntAble FuncC BoolExpr AssignS Stmt IfS IfSCom Block StmtList

%%
Program : PHPSTART StmtList PHPEND { 
                eval($2);
         }
        | OTHER Program  { printf("%s", $1); }
        ;
StmtList: Stmt StmtList { 
                struct ast* l = $2;
                struct ast_stack *stmt_list = NULL;
                if (l != NULL) {
                        stmt_list = ((struct block*)l)->stmts;
                }
                insert_to_stack(&stmt_list, $1);
                $$ = new_stmt_list(stmt_list);
        }
        |    { $$ = NULL; }
        ;
Stmt    : IfS   { $$ = $1; }
        | AssignS ';' { $$ = $1; }
        | WhileS 
        | ForS 
        | Expr ';' { $$ = $1; }
        | FuncC ';' { $$ = $1; }
        | FuncS
        | ECHO_S PrntAble ';' { $$ = create_ast(S_ECHO, $2, NULL); }
        ;
PrntAble: STRING { $$ = new_string($1); }
        | BoolExpr {
                $$ = $1;
        }
        | Expr { $$ = $1; }
        | PrntAble '.' PrntAble {
                $$ = create_ast(OP_CONCAT, $1, $3);
        }
        ;
Block   : '{' StmtList '}' { $$ = $2 ; }
        | Stmt { $$ = $1; }
        ;
AssignS : IDENTIFIER '=' Expr  { $$ = create_ast(S_ASSIGN, new_string($1), $3); }
        | IDENTIFIER '=' BoolExpr  { $$ = create_ast(S_ASSIGN, new_string($1), $3); }
        | IDENTIFIER '=' STRING { $$ = create_ast(S_ASSIGN, new_string($1), new_string($3)); } 
        | IDENTIFIER '=' FuncC { $$ = create_ast(S_ASSIGN, new_string($1), $3);}
        ;
FuncS   : FUNCTION IDENTIFIER_NAME '(' Id_seq ')' Block
        ;
IfS     : IfSCom ElseS  { $$ = $1; }
        ;
ElseS   : ELSE Block
        | ELSEIF '(' BoolExpr ')' Block ElseS
        |
        ;
IfSCom  : IF '(' BoolExpr ')' Block { $$ = new_flow(F_IF_STATMENT, $3, $5, NULL); } 
        ; 
WhileS  : WHILE '(' BoolExpr ')' Block
        ;
ForS    : FOR '(' Expr ';' BoolExpr ';' Expr ')' Block
        ;
BoolExpr: Expr '<' Expr   { $$ = create_ast(E_LT, $1, $3); }
        | Expr '>' Expr   { $$ = create_ast(E_GT, $1, $3); }
        | Expr LE Expr    { $$ = create_ast(E_LE, $1, $3); }
        | Expr GE Expr    { $$ = create_ast(E_GE, $1, $3); }
        | Expr EE Expr    { $$ = create_ast(E_EE, $1, $3); }
        | '!' BoolExpr    { $$ = create_ast(E_NOT, NULL, $2); }
        | Expr NE Expr    { $$ = create_ast(E_NE, $1, $3); }
        | '(' BoolExpr ')' { $$ = $2; }
        | BoolExpr AND BoolExpr { $$ = create_ast(E_AND, $1, $3); }
        | BoolExpr OR BoolExpr { $$ = create_ast(E_OR, $1, $3); }
        | TRUE         {$$ = new_bool(1);}
        | FALSE        {$$ = new_bool(0);}
        ;
Expr    : Expr '+' Expr  { $$ = create_ast(E_ADD, $1, $3); }
        | Expr '-' Expr  { $$ = create_ast(E_SUB, $1, $3); }
        | Expr '*' Expr  { $$ = create_ast(E_MUL, $1, $3); }
        | Expr '%' Expr  { $$ = create_ast(E_MOD, $1, $3); }
        | Expr '/' Expr  { $$ = create_ast(E_DIV, $1, $3); }
        | '(' Expr ')'   { $$ = $2; }
        /* | '+' Expr       { $$ = $2; }
        | '-' Expr       { $$ = -1 * $2;} */
        | IDENTIFIER     { 
                $$ = create_ast(SYMBOL, new_string($1), NULL);
        }
        | FLOAT    { $$ = new_double($1); }
        | INTEGER  { $$ = new_integer($1); }
        ;
/* Function Call */
FuncC   : IDENTIFIER_NAME '(' Id_seq ')'  {
        //   struct symbol_table_rec* node = search_symbol(symbol_table_head, $1);
        //   if (node) {
        //     $$ = node->data.fun();
        //   } else {
        //     yyerror("function not defined");
        //   }
        }
        ;
Id_seq  : IDENTIFIER ',' Id_seq
        |
        ;
%%


void yyerror(const char* message) {
  fprintf(stderr, "Error: %s,", message);
}

void init() {
  /* insert_to_symbol_table(&symbol_table_head, create("webserver", FUNCTION_VALUE, (void*)webserver));
  insert_to_symbol_table(&symbol_table_head, create("read", FUNCTION_VALUE, (void*)read_string));
  insert_to_symbol_table(&symbol_table_head, create("get_query_string", FUNCTION_VALUE, (void*)get_query_string )); */
}