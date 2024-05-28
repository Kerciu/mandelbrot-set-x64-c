#ifndef MANDELBROT_TOOLS_H
#define MANDELBROT_TOOLS_H

#include <stdlib.h>
#include <stddef.h>
#include "Complex.h"

void createMandelbrotAssemblified(unsigned char* pixelBuffer, int width, int height,
    int processPower, int setPoint, double centerReal, double centerImag, double zoom);

#endif
