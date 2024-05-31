#include "mandelbrotTools.h"

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

void createMandelbrot(uint8_t* pixelBuffer, int width, int height,
    int processPower, int setPoint, double centerReal, double centerImag, double zoom)
    {
    if (pixelBuffer == NULL || width <= 0 || height <= 0) {
        return;
    }

    int bufferSize = width * height * 4;
    int idx = 0;

    for (double y = 0; y < height; ++y) {
        for (double x = 0; x < width; ++x) {
            if (idx >= bufferSize) return;

            double xReal = (x - width / 2.0) * 4.0 / (width * zoom) + centerReal;
            double yReal = (y - height / 2.0) * 4.0 / (height * zoom) + centerImag;

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

            }
            else {
                pixelBuffer[idx++] = (iters * 10) % 255; // R
                pixelBuffer[idx++] = (iters * 15) % 255; // G
                pixelBuffer[idx++] = (iters * 20) % 255; // B
                pixelBuffer[idx++] = 255; // A
            }
        }
    }
}

void createMandelbrotAssemblified(uint8_t* pixelBuffer, long width, long height,
                      long processPower, long setPoint, double centerReal,
                      double centerImag, double zoom) {
    if (pixelBuffer == NULL || width <= 0 || height <= 0) {
        return;
    }

    long bufferSize = width * height * 4;

    for (long y = 0; y < height; ++y) {
        for (long x = 0; x < width; ++x) {
            // ((((x / width) - 0.5) * 4.0 / zoom) + centerReal)
            double cReal = (4 * (double) x - 2 * (double) width) / (width * zoom) + centerReal;
            // ((((y / height) - 0.5) * 4.0 / zoom) + centerImag)
            double cImag = (4 * (double) y - 2 * (double) height) / (height * zoom) + centerImag;

            double zReal = 0.0;
            double zImag = 0.0;

            // z = z ** 2 + c ; Iterate in order to check whether c is in mandelbrot set
            long iter;
            for (iter = 0; iter < processPower; ++iter) {

                double complexSquaredReal = zReal * zReal - zImag * zImag;
                double complexSquaredImag = 2 * zReal * zImag;

                zReal = complexSquaredReal + cReal;
                zImag = complexSquaredImag + cImag;

                // Check if this point is still in the set
                double complexNorm = zReal * zReal + zImag * zImag;
                if (complexNorm > setPoint * setPoint) {
                    break;
                }
            }

            uint8_t r, g, b, a;
            if (iter == processPower) {
                r = 0;
                g = 0;
                b = 0;
                a = 255;
            } else {
                r = (iter * 255) / processPower;
                g = (iter * 255) / processPower;
                b = (iter * 255) / processPower;
                a = 255;
            }

            int pixelIdx = 4 * (y * width + x);

            if (pixelIdx + 3 >= bufferSize) return;

            *(pixelBuffer + pixelIdx) = r;
            *(pixelBuffer + pixelIdx + 1) = g;
            *(pixelBuffer + pixelIdx + 2) = b;
            *(pixelBuffer + pixelIdx + 3) = a;
            }
        }
    }
