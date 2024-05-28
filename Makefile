EXEFILE = program
OBJECTS = main.o mandelbrot.o
CCFMT = -m64
NASMFMT = -f elf64
NASMOPT = -w+all

CC = gcc
CFLAGS = -c -g -Wall -Wextra
LDFLAGS = -lmingw32 -lSDL2main -lSDL2

NASM_PATH = C:/Users/Kacper/AppData/Local/NASM/nasm.exe
SDL_PATH = C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c/src/include/SDL2
LIB_PATH = C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c/src/lib

%.o: %.c
	$(CC) $(CCFMT) $(CFLAGS) -o $@ $<

%.o: %.s
	$(NASM_PATH) $(NASMFMT) $(NASMOPT) -o $@ $<

$(EXEFILE): $(OBJECTS)
	$(CC) $(CCFMT) -o $@ $^ $(LDFLAGS) -L $(LIB_PATH) -I $(SDL_PATH)

clean:
	del *.o $(EXEFILE).exe
