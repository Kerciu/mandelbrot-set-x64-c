#include "mandelbrotTools.h"

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

int* mandelbrotIterationTable(int* iterationTable, int size,
    double interpolX1, double interpolX2, double interpolY1,
    double interpolY2, int processPower, int setPoint)
    {
    int idx = 0;

    for (double x = 0; x < 1.0; x += 0.01) {
        for (double y = 0; y < 1.0; y += 0.01) {

            // Get interpolation
            double xAxis =  linearInterpolation(x, interpolX1, interpolX2);
            double yAxis = linearInterpolation(y, interpolY1, interpolY2);

            Complex* num = (Complex*)malloc(sizeof(Complex));
            num->x = xAxis;
            num->y = yAxis;
            int iter = isInMandelbrotSet(num, processPower, setPoint);
            free(num);
            iterationTable[idx++] = iter;
        }
    }
    return iterationTable;
}