#include "Complex.h"

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
