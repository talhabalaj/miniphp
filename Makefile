all: 
	bison -d miniphp.y -Wcounterexamples
	flex miniphp.l
	gcc -g -o miniphp lex.yy.c miniphp.tab.c 

clean:
	rm miniphp miniphp.tab* lex.yy.c 

install:
	cp miniphp /usr/bin/

uninstall:
	rm /usr/bin/miniphp