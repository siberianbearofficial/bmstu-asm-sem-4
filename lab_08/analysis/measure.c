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
    printf("-- pi = %f\t\tc: %f\tasm: %f\n", pi, sin_c(pi), sin_asm(pi));
}

void measure_sinus_fldpi() {
    float result;
    asm(
        "fldpi;"
        "fsin;"
        "fstps %0;"

        : "=m"(result)
    );
    printf("-- fldpi: %f\n", result);
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
    printf("-- fldpi / 2: %f\n", result);
}
