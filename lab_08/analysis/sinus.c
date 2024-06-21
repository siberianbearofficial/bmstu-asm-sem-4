#include "sinus.h"

float sin_c(float pi)
{
    float result = 0;

    result = sin(pi);

    return result;
}

float sin_asm(float pi)
{
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
