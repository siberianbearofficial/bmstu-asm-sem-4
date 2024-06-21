#include "float_32.h"

void float_sum_c(float a, float b)
{
    float res;
    res = a + b;
}

void float_sum_asm(float a, float b)
{
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

void float_mult_c(float a, float b)
{
    float res;
    res = a * b;
}

void float_mult_asm(float a, float b)
{
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
