#include <stdlib.h>
#include <math.h>

typedef struct complex {
    double x; // Real portion
    double y; // Imaginary portion
} Complex;

Complex* complexSquared(Complex* num) {
    Complex* newComplex = (Complex*)malloc(sizeof(Complex));
    if (newComplex == NULL) return NULL;

    // x^2 + 2jxy - y^2
    newComplex->x = pow(num->x, 2) - pow(num->y, 2);
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
    Complex* z = (Complex*)malloc(sizeof(Complex));
    if (z == NULL) return -1;

    z->x = 0;
    z->y = 0;

    // z = z ** 2 + c ; Iterate in order to check whether c is in mandelbrot set
    for (int i = 0; i < processPower; ++i) {
        Complex* zPowered = complexSquared(z, 2);
        if (zPowered == NULL)
        {
            free(z);
            return -1;
        }
        Complex* zAdded = complexAdd(zPowered, c);
        free(zPowered);
        if (zAdded == NULL)
        {
            free(z);
            return -1;
        }

        free(z);
        z = zAdded;

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