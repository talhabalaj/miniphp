%{
  #include <stdlib.h>
  #include "miniphp.tab.h"
  #include <string.h>
  int line_no = 0;

  char* process_string(char* ); 
  char* remove_dollar_prefix_from_string(char* ); 
  extern char* init_c_function_interop();
%}

digit [0-9]
digit_s {digit}+
nonzero_digit [1-9]
input_chars [^\n]
integer [+|-]?({nonzero_digit}{digit}*|0)
float {integer}?"."{digit_s}([eE][+|-]?{digit_s})*
letter [A-Za-z]
identifier_name ("_"|{letter})({digit}|{letter}|"_")*
single_quote_string  \'[^\'\n]*\'
double_quote_string \"[^\"\n]*\"
single_line_comment (\/\/|"#"){input_chars}*\n
del [\n\t\r ] 

%%
\n    {line_no++;}
{del}
{single_line_comment}
"/*"(.|\n)*"*/"	
"<?php"   return PHPSTART;
"?>"      return PHPEND;
"abstract" return ABSTRACT;
"array" return ARRAY;
"as" return AS;
"break" return BREAK;
"callable" return CALLABLE;
"case" return CASE;
"catch" return CATCH;
"class" return CLASS;
"clone" return CLONE;
"const" return CONST;
"continue" return CONTINUE;
"declare" return DECLARE;
"default" return DEFAULT;
"die" return DIE;
"do" return DO;
"echo" return ECHO_S;
"else" return ELSE;
"elseif" return ELSEIF;
"empty" return EMPTY;
"enddeclare" return ENDDECLARE;
"endfor" return ENDFOR;
"endforeach" return ENDFOREACH;
"endif" return ENDIF;
"endswitch" return ENDSWITCH;
"endwhile" return ENDWHILE;
"eval" return EVAL;
"exit" return EXIT;
"extends" return EXTENDS;
"final" return FINAL;
"finally" return FINALLY;
"for" return FOR;
"foreach" return FOREACH;
"function" return FUNCTION;
"global" return GLOBAL;
"goto" return GOTO;
"if" return IF;
"implements" return IMPLEMENTS;
"include" return INCLUDE;
"include_once" return INCLUDE_ONCE;
"instanceof" return INSTANCEOF;
"insteadof" return INSTEADOF;
"interface" return INTERFACE;
"isset" return ISSET;
"list" return LIST;
"namespace" return NAMESPACE;
"new" return NEW;
"print" return PRINT;
"private" return PRIVATE;
"protected" return PROTECTED;
"public" return PUBLIC;
"require" return REQUIRE;
"require_once" return REQUIRE_ONCE;
"return" return RETURN;
"static" return STATIC;
"switch" return SWITCH;
"throw" return THROW;
"trait" return TRAIT;
"try" return TRY;
"unset" return UNSET;
"use" return USE;
"var" return VAR;
"while" return WHILE;
"xor" return XOR;
"true"  {yylval.boolean = 1; return TRUE;}
"false" {yylval.boolean = 0; return FALSE;}
{integer}  {yylval.itype = atoi(yytext); return INTEGER;}
{float}    {yylval.dtype = atof(yytext); return FLOAT;}
({double_quote_string}|{single_quote_string}) {yylval.string = process_string(yytext); return STRING;}
"$".{identifier_name} {yylval.string = remove_dollar_prefix_from_string(yytext); return IDENTIFIER;}
{identifier_name}     {yylval.string = strdup(yytext); return IDENTIFIER_NAME;}
"["|"]"|"("|")"|"{"|"}"|"."|"*"|"+"|"-"|"~"|"!"|"$"|"/"|"%"|"^"|"&"|"?"|":"|";"|"="|","|"<"|">" return yytext[0];
"<=" return LE;
">=" return GE;
"==" return EE;
"!=" return NE;
"&&" return AND;
"||" return OR;
. {
  fprintf(stderr, "Error: %s token is not valid", yytext);
  exit(2);
}
%%


char* remove_dollar_prefix_from_string(char* str) {
  char* new_str = strdup(str);
  ++new_str;
  return new_str;
}

char* process_string(char* str) {
  char* new_str = strdup(str);
  ++new_str;
  new_str[strlen(new_str) - 1] = 0;

  int len = strlen(new_str);
  char buffer[2] = "";
  int bufIndex = 0;
  for (int i = 0; i < len; i++) 
  {
    if (!bufIndex && new_str[i] == '\\') {
      buffer[bufIndex++] = new_str[i];
    }

    if (bufIndex > 0 && (new_str[i] == 'n' || new_str[i] == 't')) {
      new_str[i-1] = new_str[i] == 'n' ? '\n' : '\t';
      int j = i;
      while (new_str[j] != '\0') {
        new_str[j] = new_str[j+1];
        j++;
      }
      bufIndex = 0;
      i--;
    }
  }    
  return new_str;
}

int yywrap(void) { 
  return 1;
}

int main(int argc, const char* argv[]) {
  if (argc >= 2) {
    yyin = fopen(argv[1], "r");
    if (!yyin) {
      fprintf(stderr, "error: %s: no such file");
      exit(-1); 
    }
  } else {
    FILE* tmp = yyin;
    yyin = fopen("input.txt", "r");
    if (!yyin) yyin = tmp;
  }

  init_c_function_interop();
  yyparse();
}