OBJS = main.c c_implementation/Complex.c c_implementation/mandelbrotTools.c

OBJ_NAME = CSDLMain

all: $(OBJS)
	gcc $(OBJS) -I C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c-sdl/src/include/SDL2 -L C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c-sdl/src/lib -w -Wl,-subsystem,windows -lmingw32 -lSDL2main -lSDL2 -o $(OBJ_NAME)
