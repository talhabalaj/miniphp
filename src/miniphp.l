%{
  #include <stdlib.h>
  #include "miniphp.tab.h"
  #include <string.h>

  char* process_string(char* ); 
  char* remove_dollar_prefix_from_string(char* ); 
  extern char* init_c_function_interop();

  FILE* token_file = NULL;
  void write_token(const char*, const char*);
%}

%option yylineno

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
\n   
{del}
{single_line_comment} { write_token("comment", yytext); }
"/*"(.|\n)*"*/"	      { write_token("comment", yytext); }
"<?php"  { write_token("keyword", yytext); return PHPSTART;}
"?>"      { write_token("keyword", yytext); return PHPEND; }
"abstract" { write_token("keyword", yytext); return ABSTRACT; }
"array" { write_token("keyword", yytext); return ARRAY; }
"as" { write_token("keyword", yytext); return AS; }
"break" { write_token("keyword", yytext); return BREAK; }
"callable" { write_token("keyword", yytext); return CALLABLE; }
"case" { write_token("keyword", yytext); return CASE; }
"catch" { write_token("keyword", yytext); return CATCH; }
"class" { write_token("keyword", yytext); return CLASS; }
"clone" { write_token("keyword", yytext); return CLONE; }
"const" { write_token("keyword", yytext); return CONST; }
"continue" { write_token("keyword", yytext); return CONTINUE; }
"declare" { write_token("keyword", yytext); return DECLARE; }
"default" { write_token("keyword", yytext); return DEFAULT; }
"die" { write_token("keyword", yytext); return DIE; }
"do" { write_token("keyword", yytext); return DO; }
"echo" { write_token("keyword", yytext); return ECHO_S; }
"else" { write_token("keyword", yytext); return ELSE; }
"elseif" { write_token("keyword", yytext); return ELSEIF; }
"empty" { write_token("keyword", yytext); return EMPTY; }
"enddeclare" { write_token("keyword", yytext); return ENDDECLARE; }
"endfor" { write_token("keyword", yytext); return ENDFOR; }
"endforeach" { write_token("keyword", yytext); return ENDFOREACH; }
"endif" { write_token("keyword", yytext); return ENDIF; }
"endswitch" { write_token("keyword", yytext); return ENDSWITCH; }
"endwhile" { write_token("keyword", yytext); return ENDWHILE; }
"eval" { write_token("keyword", yytext); return EVAL; }
"exit" { write_token("keyword", yytext); return EXIT; }
"extends" { write_token("keyword", yytext); return EXTENDS; }
"final" { write_token("keyword", yytext); return FINAL; }
"finally" { write_token("keyword", yytext); return FINALLY; }
"for" { write_token("keyword", yytext); return FOR; }
"foreach" { write_token("keyword", yytext); return FOREACH; }
"function" { write_token("keyword", yytext); return FUNCTION; }
"global" { write_token("keyword", yytext); return GLOBAL; }
"goto" { write_token("keyword", yytext); return GOTO; }
"if" { write_token("keyword", yytext); return IF; }
"implements" { write_token("keyword", yytext); return IMPLEMENTS; }
"include" { write_token("keyword", yytext); return INCLUDE; }
"include_once" { write_token("keyword", yytext); return INCLUDE_ONCE; }
"instanceof" { write_token("keyword", yytext); return INSTANCEOF; }
"insteadof" { write_token("keyword", yytext); return INSTEADOF; }
"interface" { write_token("keyword", yytext); return INTERFACE; }
"isset" { write_token("keyword", yytext); return ISSET; }
"list" { write_token("keyword", yytext); return LIST; }
"namespace" { write_token("keyword", yytext); return NAMESPACE; }
"new" { write_token("keyword", yytext); return NEW; }
"print" { write_token("keyword", yytext); return PRINT; }
"private" { write_token("keyword", yytext); return PRIVATE; }
"protected" { write_token("keyword", yytext); return PROTECTED; }
"public" { write_token("keyword", yytext); return PUBLIC; }
"require" { write_token("keyword", yytext); return REQUIRE; }
"require_once" { write_token("keyword", yytext); return REQUIRE_ONCE; }
"return" { write_token("keyword", yytext); return RETURN; }
"static" { write_token("keyword", yytext); return STATIC; }
"switch" { write_token("keyword", yytext); return SWITCH; }
"throw" { write_token("keyword", yytext); return THROW; }
"trait" { write_token("keyword", yytext); return TRAIT; }
"try" { write_token("keyword", yytext); return TRY; }
"unset" { write_token("keyword", yytext); return UNSET; }
"use" { write_token("keyword", yytext); return USE; }
"var" { write_token("keyword", yytext); return VAR; }
"while" { write_token("keyword", yytext); return WHILE; }
"xor" { write_token("keyword", yytext); return XOR; }
"true"  {yylval.boolean = 1; write_token("bool", yytext); return TRUE;}
"false" {yylval.boolean = 0; write_token("bool", yytext); return FALSE;}
{integer}  {yylval.itype = atoi(yytext); write_token("integer", yytext); return INTEGER;}
{float}    {yylval.dtype = atof(yytext); write_token("float", yytext); return FLOAT;}
({double_quote_string}|{single_quote_string}) {yylval.string = process_string(yytext); write_token("string", yytext); return STRING;}
"$".{identifier_name} {yylval.string = remove_dollar_prefix_from_string(yytext); write_token("id", yytext); return IDENTIFIER;}
{identifier_name}     {yylval.string = strdup(yytext); write_token("fnc", yytext); return IDENTIFIER_NAME;}
"["|"]"|"("|")"|"{"|"}"|"."|"*"|"+"|"-"|"~"|"!"|"$"|"/"|"%"|"^"|"&"|"?"|":"|";"|"="|","|"<"|">" write_token("op", yytext); return yytext[0];
"<=" { write_token("op", yytext); return LE; }
">=" { write_token("op", yytext); return GE; }
"==" { write_token("op", yytext); return EE; }
"!=" { write_token("op", yytext); return NE; }
"&&" { write_token("op", yytext); return AND; }
"||" { write_token("op", yytext); return OR; }
. {
  fprintf(stderr, "Error: %s token is not valid at %d", yytext, yylineno);
  exit(2);
}
%%


char* remove_dollar_prefix_from_string(char* str) {
  char* new_str = strdup(str);
  ++new_str;
  return new_str;
}

void write_token(const char* name, const char* value) {
  fprintf(token_file, "<%s, %s>", name, value);
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
      fprintf(stderr, "error: %s: no such file", argv[2]);
      exit(-1); 
    }
  } else {
    FILE* tmp = yyin;
    yyin = fopen("input.txt", "r");
    if (!yyin) yyin = tmp;
  }

  token_file = fopen("token.txt", "w");

  init_c_function_interop();
  yyparse();
}