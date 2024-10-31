MAIN = mem
SRC = $(wildcard ./src/*.c)
OBJ = $(patsubst %.c, %.o, $(SRC))

$(MAIN): $(OBJ)
	gcc -o $@ $^ -lcstd

debug:
	gcc -o $(MAIN) $(SRC) -lcstd -g

%.o: %.c
	gcc -o $@ -c $<

clean:
	rm $(MAIN) $(OBJ)
