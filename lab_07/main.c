#include <stdio.h>
#include <stdlib.h>

// Объявление ассемблерной функции
extern long add_numbers(long a, long b);

long add_numbers_ins(long a, long b) {
    long result;

    // Ассемблерная вставка для 64-битных регистров
    __asm__ (
            "addq %%rbx, %%rax;"
            : "=a" (result)
            : "a" (a), "b" (b)
            );

    return result;
}

int main(void) {
    long num1, num2, result;

    scanf("%ld %ld", &num1, &num2);

    result = add_numbers(num1, num2);
    printf("Result: %ld\n", result);

    result = add_numbers_ins(num1, num2);
    printf("Result ins: %ld\n", result);

    return EXIT_SUCCESS;
}
