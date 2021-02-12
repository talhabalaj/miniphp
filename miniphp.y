%{
  #include <stdio.h>
  int yylex();
  void yyerror(const char*);
%}

%token PHPSTART PHPEND INTEGER FLOAT STRING IDENTIFIER IDENTIFIER_NAME ABSTRACT AND ARRAY AS BREAK CALLABLE CASE CATCH CLASS CLONE CONST CONTINUE DECLARE DEFAULT DIE DO ECHO_S ELSE ELSEIF EMPTY ENDDECLARE ENDFOR ENDFOREACH ENDIF ENDSWITCH ENDWHILE EVAL EXIT EXTENDS FINAL FINALLY FOR FOREACH FUNCTION GLOBAL GOTO IF IMPLEMENTS INCLUDE INCLUDE_ONCE INSTANCEOF INSTEADOF INTERFACE ISSET LIST NAMESPACE NEW OR PRINT PRIVATE PROTECTED PUBLIC REQUIRE REQUIRE_ONCE RETURN STATIC SWITCH THROW TRAIT TRY UNSET USE VAR WHILE XOR LE
GE EE NE

%left ';'
%left '+' '-' 
%left '%' '/' '*'
%left '.'
%left AND OR
%left '!'

%%
Program : PHPSTART StmtList PHPEND   {
          printf("Successful");
        }
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
        | ECHO_S PrntAble ';'
        ;
PrntAble: STRING 
        | FLOAT
        | INTEGER
        | IDENTIFIER
        | PrntAble '.' PrntAble
        ;
Block   : '{' StmtList '}'
        | Stmt ';'
        ;
AssignS : IDENTIFIER '=' Expr 
        ;
FuncS   : FUNCTION IDENTIFIER_NAME '(' Id_seq ')' Block
        ;
IfS     : IfSCom
        | IfSCom ELSE Block
        ;
IfSCom  : IF '(' BoolExpr ')' Block ;
WhileS  : WHILE '(' BoolExpr ')' Block 
        ;
ForS    : FOR '(' Expr ';' BoolExpr ';' Expr ')' Block 
        ;
BoolExpr: Expr CpOp Expr
        | Expr EE Expr
        | '!' BoolExpr
        | Expr NE Expr
        | '(' BoolExpr ')'
        | BoolExpr AND BoolExpr
        | BoolExpr OR BoolExpr
        ;
CpOp    : '<'
        | GE
        | '>'
        | LE
        ;
Expr    : Expr '+' Expr
        | Expr '-' Expr
        | Expr '*' Expr
        | '(' Expr ')'
        | '+' Expr 
        | '-' Expr
        | Expr '+' '+'
        | Expr '-' '-'
        | FuncC
        | IDENTIFIER
        | INTEGER
        | FLOAT
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

int main(int argc, const char* argv[]) {
  yyparse();
}