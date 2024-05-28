CC = gcc
CFLAGS=-m64 -Wextra -Wall
C_SRC = main.c c_implementation/Complex.c c_implementation/mandelbrotTools.c
NASM_PATH = /mnt/c/Users/Kacper/AppData/Local/NASM/nasm.exe
OBJ_NAME = mandelbrot
SDL_PATH = C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c-sdl/src/include/SDL2
LIB_PATH = C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c-sdl/src/lib

all: $(OBJ_NAME)

$(OBJ_NAME): $(C_SRC:.c=.o) mandelbrot.o
	$(CC) $(C_SRC:.c=.o) -g mandelbrot.o -I $(SDL_PATH) -L $(LIB_PATH) -Wl,-subsystem,windows -lmingw32 -lSDL2main -lSDL2 -o $(OBJ_NAME)

main.o: main.c mandelbrot.h
	$(CC) $(CFLAGS) -c main.c

mandelbrot.o: mandelbrot.s
	$(NASM_PATH) -g -f elf64 mandelbrot.s -o mandelbrot.o

clean:
	rm -f *.o c_implementation/*.o $(OBJ_NAME)