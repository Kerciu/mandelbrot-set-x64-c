#ifndef COMPLEX_H
#define COMPLEX_H

#include "math.h"

typedef struct complex {
    double x;
    double y;
} Complex;

Complex* complexSquared(Complex* num);
Complex* complexAdd(Complex* a, Complex* b);
double complexNorm(Complex* num);

#endif
