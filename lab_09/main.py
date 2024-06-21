"""
Скрипт для создания BMP изображений для тестирования основной программы.
"""

from PIL import Image, ImageEnhance
import numpy as np


def gradient(array, width, height):
    v = [200, 0, 0]
    thickness = 8
    a = 1
    for i in range(0, width, thickness):
        for j in range(0, height, thickness):
            for k in range(i, i + thickness):
                for l in range(j, j + thickness):
                    array[min(k, height - 1)][min(l, width - 1)] = v
            v[2] += a
            v[2] = max(min(v[2], 180), 0)
            if v[2] >= 180:
                a *= -1


def monotone(array, width, height):
    v = [200, 0, 0]
    for i in range(width):
        for j in range(height):
            array[i][j] = v


def generate(grad: bool = False):
    # Генерация изображения
    width, height = 128, 128
    array = np.zeros((height, width, 3), dtype=np.uint8)
    if grad:
        gradient(array, width, height)
    else:
        monotone(array, width, height)
    return array


random_image = Image.fromarray(generate(input('Create gradient (y/n)? ').lower().strip() == 'y'))
random_image.save('input.bmp')

if input('Create output (y/n)? ').lower().strip() == 'y':
    # Изменение яркости изображения
    image = Image.open('input.bmp')
    enhancer = ImageEnhance.Brightness(image)
    brightness_factor = 1.5
    bright_image = enhancer.enhance(brightness_factor)
    bright_image.save('output.bmp')
