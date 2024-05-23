CC = gcc
CFLAGS = -g -I../include
LDFLAGS = -L../lib -lglfw -lm
SRC = ../src/main.c ../src/glad.c ../src/c_implementation/*.c

all: main

main: $(SRC)
	$(CC) $(CFLAGS) $(SRC) $(LDFLAGS) -o $@

clean:
	rm -f main
