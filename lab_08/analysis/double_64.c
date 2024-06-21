#include "double_64.h"

void double_sum_c(double a, double b)
{
    double result = 0;
    result = a + b;
}

void double_sum_asm(double a, double b)
{
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

void double_mult_c(double a, double b)
{
    double res;
    res = a * b;
}

void double_mult_asm(double a, double b)
{
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
