all: 
	bison -d miniphp.y -Wcounterexamples
	flex miniphp.l
	gcc -g -o miniphp lex.yy.c miniphp.tab.c 
