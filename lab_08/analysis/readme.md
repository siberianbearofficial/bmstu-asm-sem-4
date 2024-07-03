# Разбор кода

Код выполняет замеры времени выполнения арифметических операций и вычисления синуса, используя как функции на языке
C, так и встроенные ассемблерные команды. Давайте разберем, как он работает и на что следует обратить внимание.

### Основная структура

1. **main.c**: Запускает измерения функций.
    ```c
    #include <stdlib.h>
    #include "measure.h"

    int main() {
        measure_arithmetic();
        measure_sinus();
        return EXIT_SUCCESS;
    }
    ```

2. **measure.h**: Заголовочный файл, который включает объявления функций для измерений.
    ```c
    #ifndef MEASURE_H
    #define MEASURE_H

    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/time.h>
    #include "float_32.h"
    #include "double_64.h"
    #include "sinus.h"

    void measure_arithmetic();
    void measure_sinus();

    #endif
    ```

3. **measure.c**: Реализует функции для измерения времени выполнения операций.
    ```c
    #include "measure.h"

    #define N 100000

    typedef void (*float_func)(float, float);
    typedef void (*double_func)(double, double);

    long measure_float(float a, float b, float_func f);
    long measure_double(double a, double b, double_func f);
    void measure_sinus_pi(float pi);
    void measure_sinus_fldpi();
    void measure_sinus_fldpi_2();

    void measure_arithmetic() {
        float fa = 2, fb = 3;
        double da = 2, db = 3;

        printf("---------|  Arithmetic  |----------------------------------------\n");

        printf("Summary\n-- float:\t\t\tc: %ld\t\tasm: %ld\n-- double:\t\t\tc: %ld\t\tasm: %ld\n",
               measure_float(fa, fb, float_sum_c),
               measure_float(fa, fb, float_sum_asm),
               measure_double(da, db, double_sum_c),
               measure_double(da, db, double_sum_asm));

        printf("Multiplication\n-- float:\t\t\tc: %ld\t\tasm: %ld\n-- double:\t\t\tc: %ld\t\tasm: %ld\n\n",
               measure_float(fa, fb, float_mult_c),
               measure_float(fa, fb, float_mult_asm),
               measure_double(da, db, double_mult_c),
               measure_double(da, db, double_mult_asm));
    }

    void measure_sinus() {
        float pi_1 = 3.14, pi_2 = 3.141596;

        printf("---------|  Sinus  |---------------------------------------------\n");

        printf("Sin(pi)\n");
        measure_sinus_pi(pi_1);
        measure_sinus_pi(pi_2);
        measure_sinus_fldpi();

        printf("\nSin(pi/2)\n");
        measure_sinus_pi(pi_1 / 2.0);
        measure_sinus_pi(pi_2 / 2.0);
        measure_sinus_fldpi_2();

        printf("\n");
    }

    long measure_float(float a, float b, float_func f) {
        struct timeval start, end;
        gettimeofday(&start, NULL);
        for (size_t i = 0; i < N; i++) f(a, b);
        gettimeofday(&end, NULL);
        return end.tv_usec - start.tv_usec;
    }

    long measure_double(double a, double b, double_func f) {
        struct timeval start, end;
        gettimeofday(&start, NULL);
        for (size_t i = 0; i < N; i++) f(a, b);
        gettimeofday(&end, NULL);
        return end.tv_usec - start.tv_usec;
    }

    void measure_sinus_pi(float pi) {
        printf("-- pi = %lf\t\tc: %lf\tasm: %lf\n", pi, sin_c(pi), sin_asm(pi));
    }

    void measure_sinus_fldpi() {
        float result;
        asm(
            "fldpi;"
            "fsin;"
            "fstps %0;"

            : "=m"(result)
        );
        printf("-- fldpi: %lf\n", result);
    }

    void measure_sinus_fldpi_2() {
        float result, a = 2.0;
        asm(
            "fldpi;"
            "flds %1;"
            "fdivp;"
            "fsin;"
            "fstps %0;"

            : "=m"(result)
            : "m"(a)
        );
        printf("-- fldpi / 2: %lf\n", result);
    }
    ```

### Операции с double и float

4. **double_64.h** и **double_64.c**: Реализуют операции сложения и умножения для типа double как на C, так и на
   ассемблере.
    ```c
    #ifndef DOUBLE_64_H
    #define DOUBLE_64_H

    void double_sum_c(double a, double b);
    void double_sum_asm(double a, double b);
    void double_mult_c(double a, double b);
    void double_mult_asm(double a, double b);

    #endif
    ```
    ```c
    #include "double_64.h"

    void double_sum_c(double a, double b) {
        double result = 0;
        result = a + b;
    }

    void double_sum_asm(double a, double b) {
        double result = 0;
        asm(
            "fldl %1;"
            "fldl %2;"
            "faddp;"
            "fstpl %0;"

            : "=m"(result)
            : "m"(a), "m"(b)
        );
    }

    void double_mult_c(double a, double b) {
        double res;
        res = a * b;
    }

    void double_mult_asm(double a, double b) {
        double result = 0;
        asm(
            "fldl %1;"
            "fldl %2;"
            "fmulp;"
            "fstpl %0;"

            : "=m"(result)
            : "m"(a), "m"(b)
        );
    }
    ```

5. **float_32.h** и **float_32.c**: Аналогичные операции для типа float.
    ```c
    #ifndef FLOAT_32_H
    #define FLOAT_32_H

    void float_sum_c(float a, float b);
    void float_sum_asm(float a, float b);
    void float_mult_c(float a, float b);
    void float_mult_asm(float a, float b);

    #endif
    ```
    ```c
    #include "float_32.h"

    void float_sum_c(float a, float b) {
        float res;
        res = a + b;
    }

    void float_sum_asm(float a, float b) {
        float result = 0;

        asm(
            "flds %1;"
            "flds %2;"
            "faddp;"
            "fstps %0;"

            : "=m"(result)
            : "m"(a), "m"(b)
        );
    }

    void float_mult_c(float a, float b) {
        float res;
        res = a * b;
    }

    void float_mult_asm(float a, float b) {
        float result = 0;
        asm(
            "flds %1;"
            "flds %2;"
            "fmulp;"
            "fstps %0;"

            : "=m"(result)
            : "m"(a), "m"(b)
        );
    }
    ```

### Вычисление синуса

6. **sinus.h** и **sinus.c**: Реализуют вычисление синуса с использованием функций из библиотеки math.h и ассемблера.
    ```c
    #ifndef SINUS_H
    #define SINUS_H

    #include <math.h>

    float sin_c(float pi);
    float sin_asm(float pi);

    #endif
    ```
    ```c
    #include "sinus.h"

    float sin_c(float pi) {
        return sin(pi);
    }

    float sin_asm(float pi) {
        float result = 0;

        asm(
            "flds %1;"
            "fsin;"
            "fstps %0;"

            : "=m"(result)
            : "m"(pi)
        );

        return result;
    }
    ```

### Пояснения

- **measure_float и measure_double**: Измеряют время выполнения функций для операций с плавающей запятой.
- **measure_sinus_pi, measure_sinus_fldpi, measure_sinus_fldpi_2**: Измеряют время выполнения вычисления синуса разными
  способами.
- **Ассемблерные вставки**: Используют инструкции x87 FPU для выполнения арифметических операций и вычислений
  тригонометрических функций.

### Рекомендации по улучшению

1. **Точность замеров**: Для более точных замеров времени выполнения используйте более точные таймеры, такие
   как `clock_gettime` с `CLOCK_MONOTONIC`.
2. **Оптимизация кода**: Оптимизируйте ассемблерный код для лучшего использования современных инструкций SIMD (например,
   SSE, AVX).
3. **Сравнение с другими методами**: Для полноты эксперимента стоит добавить сравнение с другими методами вычислений,
   например, использованием библиотек, оптимизированных для SIMD.

Этот код уже демонстрирует основные подходы к измерению производительности, но всегда есть возможность для дальнейшего
улучшения и оптимизации.
