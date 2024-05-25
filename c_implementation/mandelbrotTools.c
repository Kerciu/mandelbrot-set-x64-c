#include "mandelbrotTools.h"

double linearInterpolation(double interpolationFactor, double a, double b) {
    return (b - a) * interpolationFactor + a ;
}


int isInMandelbrotSet(Complex* c, int processPower, int setPoint) {
    if (c == NULL) return -1;

    Complex* z = (Complex*)malloc(sizeof(Complex));
    if (z == NULL) return -1;

    z->x = 0;
    z->y = 0;

    // z = z ** 2 + c ; Iterate in order to check whether c is in mandelbrot set
    for (int i = 0; i < processPower; ++i) {
        Complex* zPowered = complexSquared(z);
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

void createMandelbrot(unsigned char* pixelBuffer, int width, int height,
                    int processPower, int setPoint)
    {
    if (pixelBuffer == NULL || width <= 0 || height <= 0) {
        return;
    }

    int bufferSize = width * height * 4;
    int idx = 0;

    for (double y = 0; y < height; ++y) {
        for (double x = 0; x < width; ++x) {
            if (idx >= bufferSize) return;

            double xReal = (double)x / width * 4.0 - 2.0;
            double yReal = (double)y / height * 4.0 - 2.0;

            // Get interpolation
            // double xAxis =  linearInterpolation(x, -2.0, 2.0);
            // double yAxis = linearInterpolation(y, -2.0, 2.0);

            Complex num = { .x = xReal, .y = yReal};
            int iters = isInMandelbrotSet(&num, processPower, setPoint);

            // Simplified

            if (iters == 0) {
                // renderer draw color (renderer , r, g, b, opacity)
                pixelBuffer[idx++] = 0; // R
                pixelBuffer[idx++] = 0; // G
                pixelBuffer[idx++] = 0; // B
                pixelBuffer[idx++] = 255; // Opacity
                // renderer draw point F (renderer, x * 1000, y * 1000)

            }
            else {
                //set renderer color (renderer, 255 - iters,255 - iters,255 - iters, 255);
                pixelBuffer[idx++] = (iters * 10) % 255; // R
                pixelBuffer[idx++] = (iters * 15) % 255; // G
                pixelBuffer[idx++] = (iters * 20) % 255; // B
                pixelBuffer[idx++] = 255; // A
            }
        }
    }
}
