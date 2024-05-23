double lerp(double interpolationFactor, double a, double b) {
    return (1 - interpolationFactor) * a + interpolationFactor * b;
}