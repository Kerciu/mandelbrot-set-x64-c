program = mandelbrot

OBJECTS = main.o mandelbrot.o

CC = gcc
NASM = nasm

CFLAGS = -c -g -Wall -Wextra -I $(SDL_PATH)

LDFLAGS = -L $(LIB_PATH) -lSDL2main -lSDL2

NASMFMT = -f elf64
NASMOPT = -w+all

SDL_PATH = /root/mandelbrot-set-x64-c/src/include/SDL2
LIB_PATH = /root/mandelbrot-set-x64-c/src/include/lib

all: $(program)

$(program): $(OBJECTS)
	$(CC) -o $(program) $(OBJECTS) $(LDFLAGS)

main.o: main.c mandelbrot.h
	$(CC) $(CFLAGS) main.c

mandelbrot.o: mandelbrot.s mandelbrot.h
	$(NASM) $(NASMFMT) $(NASMOPT) mandelbrot.s -o mandelbrot.o

clean:
	rm -f *.o $(program)
