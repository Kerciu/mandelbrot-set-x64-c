#ifndef MANDELBROT_SET
#define MANDELBROT_SET

int mandelbrot(unsigned char* pixelBuffer, int width, int height, double cReal, double cImag,
               int processPower, int setPoint, double centerReal, double centerImag, double zoom);

#endif