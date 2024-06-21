#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <immintrin.h>
#include <math.h>

#include "bmp.h"

// Функция на ассемблере для изменения яркости
void change_brightness_avx(double *data, int width, int height, int channels, double brightness) {
    int size = width * height * channels;

    __m256d factor = _mm256_set1_pd(brightness);
    __m256d factor_white = _mm256_set1_pd(1.0);

    for (int i = 0; i < size; i += 4) {
        asm (
            "vmovupd (%0), %%ymm0;"      // Загружаем 4 double в ymm0
            "vmulpd %2, %%ymm0, %%ymm1;" // Умножаем на фактор
            "vminpd %3, %%ymm1, %%ymm1;" // Ограничиваем значения 1.0
            "vmovupd %%ymm1, (%1);"      // Записываем результат обратно в память
            :
            : "r"(data + i), "r"(data + i), "x"(factor), "x"(factor_white)
            : "ymm0", "ymm1"
        );
    }
}

int main() {
    int width = 128;  // ширина изображения
    int height = 128; // высота изображения
    int channels = 3; // число каналов (RGB)
    double brightness = 1.5; // коэффициент изменения яркости

    double *image = bmp_load_image("input.bmp", &width, &height, &channels);
    if (!image) {
        fprintf(stderr, "Failed to load input image\n");
        return EXIT_FAILURE;
    }

    change_brightness_avx(image, width, height, channels, brightness);

    if (bmp_save_image("output.bmp", image, width, height, channels) != 0) {
        fprintf(stderr, "Failed to save output image\n");
        free(image);
        return EXIT_FAILURE;
    }

    free(image);

    return EXIT_SUCCESS;
}
