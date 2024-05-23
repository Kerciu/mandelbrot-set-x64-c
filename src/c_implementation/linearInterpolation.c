#include "linearInterpolation.h"

double linearInterpolation(double interpolationFactor, double a, double b) {
    return (b - a) * interpolationFactor + a ;
}
