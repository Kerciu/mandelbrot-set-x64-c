#ifndef MANDELBROT_TOOLS_H
#define MANDELBROT_TOOLS_H

#include <stdlib.h>
#include "Complex.h"
#include "linearInterpolation.h"

int isInMandelbrotSet(Complex* c, int processPower, int setPoint);
int* mandelbrotIterationTable(int* iterationTable, int size);

#endif
