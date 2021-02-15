CXX = gcc
CFLAGS = -g 
LBLIBS = -lm

SRC = symbol_table.c helpers.c ast.c miniphp.tab.c lex.yy.c  
OBJ = $(SRC:.c=.o)
EXEC = miniphp

all: ly $(EXEC)

ly: 
	@flex miniphp.l 2> /dev/null
	@bison -d miniphp.y 2> /dev/null

$(EXEC): $(OBJ)
	gcc -ggdb -o $@ $(OBJ) $(LBLIBS)

clean:
	rm -rf $(OBJ) $(EXEC)
	rm -rf miniphp.tab.* lex.yy*