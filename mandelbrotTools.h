#ifndef MANDELBROT_TOOLS_H
#define MANDELBROT_TOOLS_H

#include <stdlib.h>
#include <stdint.h>
#include "Complex.h"

void createMandelbrotAssemblified(uint8_t* pixelBuffer, long width, long height,
                      long processPower, long setPoint, double centerReal,
                      double centerImag, double zoom);

#endif
