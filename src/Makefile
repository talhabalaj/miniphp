CXX = gcc
CXXFLAGS = -Wall -Werror -Wextra -pedantic -g 
LBLIBS = -lm

SRC = miniphp.tab.c symbol_table.c helpers.c ast.c lex.yy.c  
OBJ = $(SRC:.c=.o)
EXEC = miniphp

all: ly $(EXEC)

ly: 
	flex miniphp.l
	bison -d miniphp.y

$(EXEC): $(OBJ)
	$(CXX) $(LDFLAGS) -o $@ $(OBJ) $(LBLIBS)

clean:
	rm -rf $(OBJ) $(EXEC)