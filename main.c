#include <stdlib.h>
#include <stdio.h>
#include "mandelbrot.h"

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Insufficient number of arguments: %d\n", argc);
        return -1;
    }
    mandelbrot(argv[1]);
    printf("Compilation test: %s\n", argv[1]);
    return 0;
}