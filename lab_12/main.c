#include <stdio.h>
#include <stdlib.h>
#include <time.h>

double vector_product(const double *a, const double *b, int length)
{
    double result = 0.0;

    for (int i = 0; i < length - 1; i += 2)
    {
        asm(
            "ld1 {v0.2d}, [%[a]], #16;"
            "ld1 {v1.2d}, [%[b]], #16;"
            "fmul v2.2d, v0.2d, v1.2d;"
            "faddp d0, v2.2d;"
            "fadd %d[result], %d[result], d0;"

            : [a] "+r" (a), [b] "+r" (b), [result] "+w" (result)
            :
            : "v0", "v1", "v2", "d0", "memory"
        );
    }

    if (length & 1)
    {
        asm(
            "ldr d0, [%[a]];"
            "ldr d1, [%[b]];"
            "fmul d2, d0, d1;"
            "fadd %d[result], %d[result], d2;"

            : [result] "+w" (result)
            : [a] "r" (a), [b] "r" (b)
            : "d0", "d1", "d2", "memory"
        );
    }

    return result;
}

void vector_print(double *v, size_t length)
{
    for (size_t i = 0; i < length; ++i)
        printf("%.6lf ", v[i]);
    printf("\n");
}

size_t my_strlen(const char *str)
{
    size_t result;

    asm(
        "mov x0, %1;"
        "mov x1, #0;"
        "1:;"
        "ldrb w2, [x0], #1;"
        "cmp w2, #0;"
        "add x1, x1, #1;"
        "bne 1b;"
        "sub x1, x1, #1;"
        "mov %0, x1;"

        : "=r" (result)
        : "r" (str)
        : "x0", "x1", "w2"
    );

    return result;
}

int main(void)
{
    double a[3] = {1, 2, 6};
    printf("a: ");
    print_vector(v1, 3);

    double b[3] = {0, 4, 1};
    printf("b: ");
    print_vector(v2, 3);

    double result = vector_product(a, b, 3);
    printf("Product: %f\n", result);

    const char *str = "Hello, World!";
    printf("String: %s\n", str);

    size_t length = mystrlen(str);
    printf("Length: %zu\n", length);

    return EXIT_SUCCESS;
}
