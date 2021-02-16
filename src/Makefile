CC = clang
CFLAGS = -g 
LBLIBS = -lm

SRC = miniphp.tab.c lex.yy.c  
OBJ = $(SRC:.c=.o)
EXEC = miniphp

all: ly $(EXEC)

ly: 
	flex miniphp.l
	bison -d miniphp.y

$(EXEC): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LBLIBS)

clean:
	rm -rf $(OBJ) $(EXEC)
	rm -rf miniphp.tab.* lex.yy*
