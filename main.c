#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c-sdl/src/include/SDL2/SDL.h>
#include "mandelbrot.h"
#include "c_implementation/mandelbrotTools.h"

#define viewportWidth 800
#define viewportHeight 600

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

const int WIDTH = 800, HEIGHT = 600;

int main( int argc, char *argv[] )
{
     SDL_Init(SDL_INIT_EVERYTHING);

    // Utworzenie okna
    SDL_Window *window = SDL_CreateWindow("Mandelbrot Set", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, SDL_WINDOW_ALLOW_HIGHDPI);

    // Utworzenie renderera
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    int width = 800;
    int height = 600;
    unsigned char* buf = (unsigned char*)malloc(width * height * 3 * sizeof(unsigned char));
    if (buf == NULL) {
        printf("Failed to allocate memory for pixel buffer\n");
        return -1;
    }
    createMandelbrot(buf, width, height, -2.0, 2.0, -2.0, 2.0, 25, 10);
    saveBMP("mandelbrot.bmp", width, height, buf);

    SDL_Texture *texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STATIC, WIDTH, HEIGHT);
    SDL_UpdateTexture(texture, NULL, buf, WIDTH * 3);

    // Główna pętla zdarzeń
    SDL_Event windowEvent;
    while (1)
    {
        if (SDL_PollEvent(&windowEvent))
        {
            if (SDL_QUIT == windowEvent.type)
            {
                break;
            }
        }

        // Wyczyść ekran
        SDL_RenderClear(renderer);

        // Renderuj teksturę na ekranie
        SDL_RenderCopy(renderer, texture, NULL, NULL);

        // Wyświetl na ekranie
        SDL_RenderPresent(renderer);
    }

    // Zwolnij zasoby
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    free(buf);
    return EXIT_SUCCESS;
}