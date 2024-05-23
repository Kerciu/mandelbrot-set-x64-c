#include <stdlib.h>
#include <math.h>

typedef struct complex {
    double x; // Real portion
    double y; // Imaginary portion
} Complex;

Complex* complexPower(Complex* num, int p) {
    Complex* newComplex = (Complex*)malloc(sizeof(Complex));
    if (newComplex == NULL) return NULL;

    // x^2 + 2jxy + y^2
    newComplex->x = pow(num->x, 2) + pow(num->y, 2);
    newComplex->y = 2 * num->x * num->y;

    return newComplex;
}

Complex* complexAdd(Complex* a, Complex* b) {
    Complex* newComplex = (Complex*)malloc(sizeof(Complex));
    if (newComplex == NULL) return NULL;

    newComplex->x = a->x + b->x;
    newComplex->y = a->y + b->y;

    return newComplex;
}

double complexNorm(Complex* num) {
    // Return square magnitude

    return sqrt(pow(num->x, 2) + pow(num->y, 2));
}

int isInMandelbrotSet(Complex* c, int processPower, int setPoint) {
    Complex* z = (double*)malloc(sizeof(Complex));
    if (z == NULL) return -1;

    z->x = 0;
    z->y = 0;

    // z = z ** 2 + c
    for (int i = 0; i < processPower; ++i) {
        Complex* temp = complexAdd(complexPower(z, 2), c);
        free(z);
        z = temp;

        if (z == NULL) return -1;

        // Check if this point is still in the set
        if (complexNorm(z) > setPoint)
        {
            free(z);
            return i;
        } // If we want to call mandelbrot set, we check how much iterations it took
    }
    free(z);
    return 0;   // This is inside the set
}