MAIN = mem
SRC = $(wildcard ./*.c)
OBJ = $(patsubst %.c, %.o, $(SRC))

$(MAIN): $(OBJ)
	gcc -o $@ $^

debug:
	gcc -o $(MAIN) $(OBJ) -g

%.o: %.c
	gcc -o $@ -c $<

clean:
	rm $(MAIN) $(OBJ)
