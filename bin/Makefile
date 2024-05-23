CC = gcc
CFLAGS = -g -I../include
LDFLAGS = -L../lib -lglfw
SRC = ../src/main.c ../src/glad.c

all: main

main: $(SRC)
	$(CC) $(CFLAGS) $(SRC) $(LDFLAGS) -o $@

clean:
	rm -f main
