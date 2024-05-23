#include <stdlib.h>

typedef struct complex {
    double x; // Real portion
    double y; // Imaginary portion
} Complex;

double pow(double num, int p) {
    double result = 1;
    for (int i = 0; i < p; i++) {
        result *= num;
    }
    return result;
}

Complex* complexPower(Complex* num, int p) {
    Complex* newComplex = (Complex*)malloc(sizeof(Complex));
    if (newComplex == NULL) return -1;

    // x^2 + 2jxy + y^2
    newComplex->x = pow(num->x, 2) + pow(num->y, 2);
    newComplex->y = 2 * num->x * num->y;

    return newComplex;
}

Complex* complexAdd(Complex* a, Complex* b) {
    Complex* newComplex = (Complex*)malloc(sizeof(Complex));
    if (newComplex == NULL) return -1;

    newComplex->x = a->x + b->x;
    newComplex->y = a->y + b->y;

    return newComplex;
}


int isInMandelbrotSet(Complex* c, int processPower) {
    Complex* z = (double*)malloc(sizeof(Complex));
    if (z == NULL) return -1;

    z->x = 0;
    z->y = 0;

    // z = z ** 2 + c
    for (int i = 0; i < processPower; ++i) {
        z = complexAdd(complexPower(z, 2), c);

        // Check if this point is still in the set
    }
}