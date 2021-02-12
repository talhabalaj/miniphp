%{
  #include <stdlib.h>
  #include "miniphp.tab.h"
  int line_no = 0;
%}

digit [0-9]
digit_s {digit}+
nonzero_digit [1-9]
input_chars [^\n]
integer [+|-]?{nonzero_digit}{digit}*
float ({integer}|0)?"."{digit_s}([eE][+|-]?{digit_s})*
letter [A-Za-z]
identifier_name ("_"|{letter})({digit}|{letter}|"_")*
single_quote_string  \'[^\'\n]*\'
double_quote_string \"[^\"\n]*\"
single_line_comment (\/\/|"#"){input_chars}*\n
del [\n\t\r ] 

%%
\n    {line_no++;}
{del}
({single_line_comment}|("/*")[^("*/")]*("*/"))
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
{integer}  return INTEGER;
{float}    return FLOAT;
({double_quote_string}|{single_quote_string}) return STRING;
"$".{identifier_name} return IDENTIFIER;
{identifier_name}     return IDENTIFIER_NAME;
"["|"]"|"("|")"|"{"|"}"|"."|"*"|"+"|"-"|"~"|"!"|"$"|"/"|"%"|"^"|"&"|"?"|":"|";"|"="|","|"<"|">" return yytext[0];
"<=" return LE;
">=" return GE;
"==" return EE;
"!=" return NE;
"&&" return AND;
"||" return OR;
.   {
  fprintf(stderr, "Error: %s is not a valid token at %d", line_no);
  exit(0);
}
%%

int yywrap(void) { 
  return 1;
}