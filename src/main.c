#include <stdlib.h>
#include <stdio.h>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "mandelbrot.h"
#include "c_implementation/mandelbrotTools.h"



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
    int* array = (int*)malloc(width * height * sizeof(int));
    if (array == NULL) {
        printf("Failed to allocate memory for Mandelbrot array\n");
        glfwTerminate();
        return -1;
    }
    mandelbrotIterationTable(array, width, height, -2.0, 2.0, -2.0, 2.0, 25, 10);

    int size = width * height;
    for (int i = 0; i < size; i++) {
        if (array[i] == 0) {
            // Black pixel
        }
        else {
            // other pixel
        }
    }


    while (!glfwWindowShouldClose(window)) {

        glfwPollEvents();

        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // TODO draw mandelbrot here

        glfwSwapBuffers(window);
    }

    glfwTerminate();
    return 0;
}
