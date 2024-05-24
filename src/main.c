#include <stdlib.h>
#include <stdio.h>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "mandelbrot.h"
#include "c_implementation/mandelbrotTools.h"

void saveBMP(const char *filename, int width, int height, unsigned char *buffer) {
    FILE *f;
    unsigned char *img = NULL;
    int filesize = 54 + 3 * width * height;

    img = (unsigned char *)malloc(3 * width * height);
    if (img == NULL) {
        printf("Failed to allocate memory for BMP\n");
        return;
    }

    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            int x = i;
            int y = (height - 1) - j;
            img[(x + y * width) * 3 + 2] = buffer[(i + j * width) * 3 + 0];
            img[(x + y * width) * 3 + 1] = buffer[(i + j * width) * 3 + 1];
            img[(x + y * width) * 3 + 0] = buffer[(i + j * width) * 3 + 2];
        }
    }

    unsigned char bmpfileheader[14] = {
        'B', 'M',  filesize & 0xFF, (filesize >> 8) & 0xFF, (filesize >> 16) & 0xFF, (filesize >> 24) & 0xFF,
        0, 0, 0, 0, 54, 0, 0, 0
    };
    unsigned char bmpinfoheader[40] = {
        40, 0, 0, 0,  width & 0xFF, (width >> 8) & 0xFF, (width >> 16) & 0xFF, (width >> 24) & 0xFF,
        height & 0xFF, (height >> 8) & 0xFF, (height >> 16) & 0xFF, (height >> 24) & 0xFF,
        1, 0, 24, 0
    };

    f = fopen(filename, "wb");
    if (f == NULL) {
        printf("Failed to open BMP file\n");
        free(img);
        return;
    }
    fwrite(bmpfileheader, 1, 14, f);
    fwrite(bmpinfoheader, 1, 40, f);
    fwrite(img, 1, 3 * width * height, f);
    fclose(f);
    free(img);
}

int main() {
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow* window = glfwCreateWindow(800, 600, "Mandelbrot Set", NULL, NULL);
    if (window == NULL) {
        printf("Failed to create GLFW window\n");
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        printf("Failed to initialize GLAD\n");
        return -1;
    }

    // Initialize mandelbrot set
    int width = 800;
    int height = 600;
    unsigned char* buf = (unsigned char*)malloc(width * height * 3 * sizeof(unsigned char));
    if (buf == NULL) {
        printf("Failed to allocate memory for pixel buffer\n");
        glfwTerminate();
        return -1;
    }
    createMandelbrot(buf, width, height, -2.0, 2.0, -2.0, 2.0, 25, 10);
    saveBMP("mandelbrot.bmp", width, height, buf);


    while (!glfwWindowShouldClose(window)) {

        glfwPollEvents();

        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // TODO draw mandelbrot here
        glDrawPixels(width, height, GL_RGB, GL_UNSIGNED_BYTE, buf);

        glfwSwapBuffers(window);
    }

    free(buf);
    glfwTerminate();
    return 0;
}
