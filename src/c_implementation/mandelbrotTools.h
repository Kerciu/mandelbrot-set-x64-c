#ifndef MANDELBROT_TOOLS_H
#define MANDELBROT_TOOLS_H

#include <stdlib.h>
#include <stddef.h>
#include "Complex.h"
#include "linearInterpolation.h"

void mandelbrotIterationTable(int* iterationTable, int width, int height,
    double interpolX1, double interpolX2, double interpolY1,
    double interpolY2, int processPower, int setPoint);

#endif
