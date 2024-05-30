#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <stdint.h>
#include <C:/Users/Kacper/Desktop/mandelbrot-set/mandelbrot-set-x64-c-sdl/src/include/SDL2/SDL.h>
#include "mandelbrot.h"
#include "mandelbrotTools.h"

void saveBMP(const char *filename, int width, int height, unsigned char *buffer) {
    FILE *f;
    unsigned char *img = NULL;
    int filesize = 54 + 4 * width * height;

    img = (unsigned char *)malloc(4 * width * height);
    if (img == NULL) {
        printf("Failed to allocate memory for BMP\n");
        return;
    }

    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            int x = i;
            int y = (height - 1) - j;
            img[(x + y * width) * 4 + 2] = buffer[(i + j * width) * 4 + 0];
            img[(x + y * width) * 4 + 1] = buffer[(i + j * width) * 4 + 1];
            img[(x + y * width) * 4 + 0] = buffer[(i + j * width) * 4 + 2];
            img[(x + y * width) * 4 + 3] = buffer[(i + j * width) * 4 + 3];
        }
    }

    unsigned char bmpfileheader[14] = {
        'B', 'M',  filesize & 0xFF, (filesize >> 8) & 0xFF, (filesize >> 16) & 0xFF, (filesize >> 24) & 0xFF,
        0, 0, 0, 0, 54, 0, 0, 0
    };
    unsigned char bmpinfoheader[40] = {
        40, 0, 0, 0,  width & 0xFF, (width >> 8) & 0xFF, (width >> 16) & 0xFF, (width >> 24) & 0xFF,
        height & 0xFF, (height >> 8) & 0xFF, (height >> 16) & 0xFF, (height >> 24) & 0xFF,
        1, 0, 32, 0
    };

    f = fopen(filename, "wb");
    if (f == NULL) {
        printf("Failed to open BMP file\n");
        free(img);
        return;
    }
    fwrite(bmpfileheader, 1, 14, f);
    fwrite(bmpinfoheader, 1, 40, f);
    fwrite(img, 1, 4 * width * height, f);
    fclose(f);
    free(img);
}

int main(int argc, char* argv[])
{
    SDL_Init(SDL_INIT_EVERYTHING);

    long WIDTH = 800;
    long HEIGHT = 600;

    // Window creation
    SDL_Window *window = SDL_CreateWindow("Mandelbrot Set", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, SDL_WINDOW_ALLOW_HIGHDPI);
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    // Mandelbrot buffer
    uint8_t* buf = (uint8_t*)malloc(WIDTH * HEIGHT * 4 * sizeof(uint8_t*));  // RGBA buf
    if (buf == NULL) {
        printf("Failed to allocate memory for pixel buffer\n");
        return -1;
    }

    double centerReal = -0.5;
    double centerImag = 0.0;
    double zoom = 1.0;
    long processPower = 100;
    long setPoint = 4;

    mandelbrot(buf, WIDTH, HEIGHT, processPower, setPoint, centerReal, centerImag, zoom);
    // createMandelbrotAssemblified(buf, WIDTH, HEIGHT, processPower, setPoint, centerReal, centerImag, zoom);
    saveBMP("mandelbrot.bmp", WIDTH, HEIGHT, buf);

    SDL_Surface* surface = SDL_CreateRGBSurfaceFrom(buf, WIDTH, HEIGHT, 32, WIDTH * 4, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);

    int quit = 0;
    SDL_Event e;
    while (!quit) {
        int needRedraw = 0;
        while (SDL_PollEvent(&e) != 0)
        {
            if (e.type == SDL_QUIT)
            {
                quit = 1;
            }
            else if (e.type == SDL_MOUSEWHEEL)
            {
                int mouseX = e.wheel.x;
                int mouseY = e.wheel.y;
                SDL_GetMouseState(&mouseX, &mouseY);
                double mouseRe = ((double)mouseX - WIDTH / 2.0) * 4.0 / (WIDTH * zoom) + centerReal;
                double mouseIm = ((double)mouseY - HEIGHT / 2.0) * 4.0 / (HEIGHT * zoom) + centerImag;

                if (e.wheel.y > 0)
                {
                    zoom *= 1.5;
                }
                else if (e.wheel.y < 0)
                {
                    zoom /= 1.5;
                }
                centerReal = mouseRe + (centerReal - mouseRe) / 1.1;
                centerImag = mouseIm + (centerImag - mouseIm) / 1.1;
                needRedraw = 1;
            }
            else if (e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT)
            {
                int mouseX = e.button.x;
                int mouseY = e.button.y;

                centerReal += (mouseX - WIDTH / 2.0) * 4.0 / (WIDTH * zoom);
                centerImag += (mouseY - HEIGHT / 2.0) * 4.0 / (HEIGHT * zoom);
                needRedraw = 1;
            }
        }
        if (needRedraw)
        {
            createMandelbrotAssemblified(buf, WIDTH, HEIGHT, processPower, setPoint, centerReal, centerImag, zoom);
            SDL_Surface* surface = SDL_CreateRGBSurfaceFrom(buf, WIDTH, HEIGHT, 32, WIDTH * 4, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
            SDL_DestroyTexture(texture);
            texture = SDL_CreateTextureFromSurface(renderer, surface);
            SDL_FreeSurface(surface);
        }
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
    }

    SDL_DestroyTexture(texture);
    free(buf);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();


    return 0;
}