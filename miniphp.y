%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include <ctype.h>
  #include "symbol_table.h"

  struct symbol_table_rec* symbol_table_head;

  int yylex();
  void yyerror(const char*);
  void fun() {
    printf("HELLO");
  }
%}

%define parse.trace

%union {
  double dtype;
  int boolean;
  int itype;
  char* string;
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



%type<dtype> Expr
%type<string> PrntAble StrExpr
%type<boolean> BoolExpr

%%
Program : PHPSTART StmtList PHPEND Program
        | OTHER Program  { printf("%s", $1); }
        | 
        ;
StmtList: Stmt StmtList
        |
        ;
Stmt    : IfS
        | AssignS ';'
        | WhileS
        | ForS
        | Expr ';' 
        | FuncS
        | ECHO_S PrntAble ';' { printf("%s", $2); }
        ;
PrntAble: STRING { $$ = $1; }
        | BoolExpr {  
                char str[6] = "false";
                if ($1) {
                        strcpy(str, "true");
                }
                $$ = str;
        }
        | StrExpr {
                $$ = $1;
        }
        | PrntAble '.' PrntAble {
                strcat($1, $3);
        }
        ;
Block   : '{' StmtList '}'
        | Stmt ';'
        ;
AssignS : IDENTIFIER '=' Expr  { 
                struct symbol_table_rec* node = search_symbol(symbol_table_head, $1);
                if (!node) {
                        void* data;
                        int type;
                        if ($3 - (int)$3 != 0) {
                                data = (float*)malloc(sizeof(float));
                                type = FLOAT_VALUE;
                                *(float*)data = $3;
                        } else {
                                data = (int*)malloc(sizeof(int));
                                type = INT_VALUE;
                                *(int*)data = $3;
                        }
                        node = create($1, type, data);
                        insert_to_symbol_table(&symbol_table_head,  node);
                } else {
                        if ($3 - (int)$3 == 0) {     
                                node->type = INT_VALUE;
                                node->data.intVal = $3;
                        } else {  
                                node->type = FLOAT_VALUE;
                                node->data.floatVal = $3;
                        }
                }
        }  
        | IDENTIFIER '=' BoolExpr  { 
                struct symbol_table_rec* node = search_symbol(symbol_table_head, $1);
                if (!node) {
                        int* data = (int*)malloc(sizeof(int));
                        *data = $3;
                        node = create($1, BOOL_VALUE, (void*)data);
                        insert_to_symbol_table(&symbol_table_head,  node);
                } else {
                        node->type = BOOL_VALUE;
                        node->data.boolVal = $3;
                }
        }
        | IDENTIFIER '=' STRING { 
                struct symbol_table_rec* node = search_symbol(symbol_table_head, $1);
                if (!node) {
                        node = create($1, STRING_VALUE, (void*)$3);
                        insert_to_symbol_table(&symbol_table_head,  node);
                } else {
                        node->type = STRING_VALUE;
                        node->data.stringVal = $3;
                }
        }
        ;
FuncS   : FUNCTION IDENTIFIER_NAME '(' Id_seq ')' Block
        ;
IfS     : IfSCom ElseS
        ;
ElseS   : ELSE Block 
        | ELSEIF '(' BoolExpr ')' Block ElseS
        |
        ;
IfSCom  : IF '(' BoolExpr ')' Block ; 
WhileS  : WHILE '(' BoolExpr ')' Block 
        ;
ForS    : FOR '(' Expr ';' BoolExpr ';' Expr ')' Block 
        ;
BoolExpr: Expr '<' Expr   { $$ = $1 < $3; }
        | Expr '>' Expr   { $$ = $1 > $3; }
        | Expr LE Expr    { $$ = $1 <= $3; }
        | Expr GE Expr    { $$ = $1 >= $3; }
        | Expr EE Expr    { $$ = $1 == $3; }
        | '!' BoolExpr    { $$ = !$2; }
        | Expr NE Expr    { $$ = $1 != $3; }
        | '(' BoolExpr ')' { $$ = $2; }
        | BoolExpr AND BoolExpr { $$ = $1 && $3; }
        | BoolExpr OR BoolExpr { $$ = $1 || $3; }
        | TRUE 
        | FALSE
        ;
StrExpr : IDENTIFIER {
                struct symbol_table_rec* node = search_symbol(symbol_table_head, $1);
                if (node) {
                        if (node->type == STRING_VALUE) {
                                $$ = node->data.stringVal;
                        } else if (node->type == FUNCTION_VALUE) {
                                yyerror("WHAT IS THIS?");
                        } else if (node->type == FLOAT_VALUE) {
                                char str[20];
                                sprintf(str, "%f", node->data.floatVal);
                                $$ = str;
                        } else if (node->type == INT_VALUE) {
                                char str[20];
                                sprintf(str, "%d", node->data.intVal);
                                $$ = str;
                        } else if (node->type == BOOL_VALUE) {
                                char str[6] = "false";
                                if (node->data.boolVal) {
                                        strcpy(str, "true");
                                }
                                $$ = str;
                        }
                } else {
                        char null[5] = "null";
                        $$ = null;
                }
        } 
        | Expr {
                char str[20];
                if ($1 - (int)$1 == 0)
                        sprintf(str, "%d", $1);
                else 
                        sprintf(str, "%f", $1);
                $$ = str;
        }
        ;
Expr    : Expr '+' Expr  { $$ = $1 + $3; }
        | Expr '-' Expr  { $$ = $1 - $3; }
        | Expr '*' Expr  { $$ = $1 * $3; }
        | Expr '%' Expr  { $$ = (int)$1 % (int)$3; }
        | Expr '/' Expr  { $$ = $1 / $3; }
        | '(' Expr ')'   { $$ = $2; }
        | '+' Expr       { $$ = $2; }
        | '-' Expr       { $$ = -1 * $2;}
        //| FuncC            
        | IDENTIFIER     {
                struct symbol_table_rec* node = search_symbol(symbol_table_head, $1);
                if (node) {
                  if (node->type == FLOAT_VALUE) {
                    $$ = node->data.floatVal;
                  } else if (node->type == INT_VALUE) {
                    $$ = (float)node->data.intVal;
                  } else {
                    yyerror("Double expect");
                  }
                } else {
                  yyerror("value none of idenitifier");
                }
        }
        | FLOAT
        | INTEGER  { $$ = (float)$<itype>1; }
        ;
/* Function Call */
FuncC   : IDENTIFIER_NAME '(' Id_seq ')'
        ;
Id_seq  : IDENTIFIER ',' Id_seq
        |
        ;
%%  

void yyerror(const char* message) {
  fprintf(stderr, "Error: %s,", message);
}

