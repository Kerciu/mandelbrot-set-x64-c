#ifndef MANDELBROT_TOOLS_H
#define MANDELBROT_TOOLS_H

#include <stdlib.h>
#include <stddef.h>
#include "Complex.h"

static double linearInterpolation(double interpolationFactor, double a, double b);

int isInMandelbrotSet(Complex* c, int processPower, int setPoint);

void createMandelbrot(unsigned char* pixelBuffer, int width, int height,
    int processPower, int setPoint, int centerReal, int centerImag, int zoom);

#endif
