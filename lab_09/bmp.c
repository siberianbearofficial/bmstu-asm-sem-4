#include "bmp.h"

#pragma pack(push, 1)
typedef struct {
    uint16_t bfType;
    uint32_t bfSize;
    uint16_t bfReserved1;
    uint16_t bfReserved2;
    uint32_t bfOffBits;
} BITMAPFILEHEADER;

typedef struct {
    uint32_t biSize;
    int32_t biWidth;
    int32_t biHeight;
    uint16_t biPlanes;
    uint16_t biBitCount;
    uint32_t biCompression;
    uint32_t biSizeImage;
    int32_t biXPelsPerMeter;
    int32_t biYPelsPerMeter;
    uint32_t biClrUsed;
    uint32_t biClrImportant;
} BITMAPINFOHEADER;
#pragma pack(pop)

void d2i(uint8_t *newData, double *data, int size) {
    for (int i = 0; i < size; i++) {
        double el = data[i];
        newData[i] = (uint8_t) (el * 255);
    }
}

void i2d(double *newData, uint8_t *data, int size) {
    for (int i = 0; i < size; i++) {
        uint8_t el = data[i];
        newData[i] = ((double) el) / 255;
    }
}

// Функция для сохранения изображения в BMP-файл
int bmp_save_image(const char *filename, double *data, int width, int height, int channels) {
    FILE *file = fopen(filename, "wb");
    if (!file) {
        perror("Failed to open file for writing");
        return -1;
    }

    BITMAPFILEHEADER fileHeader;
    BITMAPINFOHEADER infoHeader;
    int padding = (4 - (width * channels) % 4) % 4;

    fileHeader.bfType = 0x4D42; // "BM"
    fileHeader.bfSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + (width * channels + padding) * height;
    fileHeader.bfReserved1 = 0;
    fileHeader.bfReserved2 = 0;
    fileHeader.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);

    infoHeader.biSize = sizeof(BITMAPINFOHEADER);
    infoHeader.biWidth = width;
    infoHeader.biHeight = -height; // Top-down BMP
    infoHeader.biPlanes = 1;
    infoHeader.biBitCount = channels * 8;
    infoHeader.biCompression = 0; // BI_RGB
    infoHeader.biSizeImage = (width * channels + padding) * height;
    infoHeader.biXPelsPerMeter = 0;
    infoHeader.biYPelsPerMeter = 0;
    infoHeader.biClrUsed = 0;
    infoHeader.biClrImportant = 0;

    fwrite(&fileHeader, sizeof(BITMAPFILEHEADER), 1, file);
    fwrite(&infoHeader, sizeof(BITMAPINFOHEADER), 1, file);

    int size = width * height * channels;
    uint8_t *newData = (uint8_t *) malloc(size * sizeof(uint8_t));
    if (!newData) {
        fclose(file);
        return -1;
    }

    d2i(newData, data, size);

    for (int y = 0; y < height; ++y) {
        fwrite(newData + y * width * channels, channels, width, file);
        for (int p = 0; p < padding; ++p)
            fputc(0, file);
    }

    free(newData);
    fclose(file);
    return 0;
}

double* bmp_load_image(const char *filename, int *width, int *height, int *channels) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("Failed to open file for reading");
        return NULL;
    }

    BITMAPFILEHEADER fileHeader;
    BITMAPINFOHEADER infoHeader;

    fread(&fileHeader, sizeof(BITMAPFILEHEADER), 1, file);
    fread(&infoHeader, sizeof(BITMAPINFOHEADER), 1, file);

    if (fileHeader.bfType != 0x4D42) { // "BM"
        fprintf(stderr, "Not a valid BMP file\n");
        fclose(file);
        return NULL;
    }

    *width = infoHeader.biWidth;
    *height = abs(infoHeader.biHeight);
    *channels = infoHeader.biBitCount / 8;

    int padding = (4 - (*width * *channels) % 4) % 4;

    int size = *width * *height * *channels;
    uint8_t *data = (uint8_t *) malloc(size * sizeof(uint8_t));
    if (!data) {
        fclose(file);
        return NULL;
    }

    fseek(file, fileHeader.bfOffBits, SEEK_SET);

    for (int y = 0; y < *height; ++y) {
        fread(data + (*height - y - 1) * *width * *channels, *channels, *width, file);
        fseek(file, padding, SEEK_CUR);
    }

    double *newData = (double *) malloc(size * sizeof(double));
    if (!newData) {
        free(data);
        fclose(file);
        return NULL;
    }

    i2d(newData, data, size);

    free(data);
    fclose(file);
    return newData;
}
