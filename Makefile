CC=gcc
CFLAGS=-m64 -Wextra -Wall

NASM_PATH = /mnt/c/Users/Kacper/AppData/Local/NASM/nasm.exe

all:	main.o mandelbrot.o
	$(CC) $(CFLAGS) -o main main.o mandelbrot.o

main.o:	main.c mandelbrot.h
	$(CC) $(CFLAGS) -c main.c -L/mingw64/lib -lmsvcrt

mandelbrot.o:	mandelbrot.s
	$(NASM_PATH) -g -f elf64 mandelbrot.s -o mandelbrot.o

clean:
	rm -f *.o