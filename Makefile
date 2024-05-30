EXEFILE = program
OBJECTS = main.o mandelbrot.o mandelbrotTools.o Complex.o
CC = gcc
CFLAGS = -c -g -Wall -Wextra -I $(SDL_PATH)
LDFLAGS = -L $(LIB_PATH) -lmingw32 -lSDL2main -lSDL2
NASMFMT = -felf64
NASMOPT = -w+all

NASM_PATH = C:/Users/Kacper/AppData/Local/NASM/nasm.exe
SDL_PATH = C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c/src/include/SDL2
LIB_PATH = C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c/src/lib

all: $(EXEFILE)

$(EXEFILE): $(OBJECTS)
	$(CC) -o $(EXEFILE) $(OBJECTS) $(LDFLAGS)

main.o: main.c mandelbrot.h
	$(CC) $(CFLAGS) main.c

mandelbrot.o: mandelbrot.s mandelbrot.h
	$(NASM_PATH) $(NASMFMT) $(NASMOPT) mandelbrot.s -o mandelbrot.o

mandelbrotTools.o: mandelbrotTools.c mandelbrotTools.h
	$(CC) $(CFLAGS) mandelbrotTools.c

Complex.o: Complex.c Complex.h
	$(CC) $(CFLAGS) Complex.c

clean:
	del *.o $(EXEFILE).exe
