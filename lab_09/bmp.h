#ifndef BMP_H
#define BMP_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int bmp_save_image(const char *filename, double *data, int width, int height, int channels);

double* bmp_load_image(const char *filename, int *width, int *height, int *channels);

#endif //BMP_H
