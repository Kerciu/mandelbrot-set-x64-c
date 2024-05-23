CC = gcc
CFLAGS = -g -Wall -Wextra -I../include
LDFLAGS = -L../lib -lglfw

NASM_PATH = /mnt/c/Users/Kacper/AppData/Local/NASM/nasm.exe

SRC_C = ../src/main.c ../src/glad.c main.c
OBJ_C = $(SRC_C:.c=.o)
OBJ_ASM = mandelbrot.o

all: main

main: $(OBJ_C) $(OBJ_ASM)
	$(CC) $(CFLAGS) -o main $(OBJ_C) $(OBJ_ASM) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

mandelbrot.o: mandelbrot.s
	$(NASM_PATH) -g -f elf64 mandelbrot.s -o mandelbrot.o

clean:
	rm -f main $(OBJ_C) $(OBJ_ASM)
