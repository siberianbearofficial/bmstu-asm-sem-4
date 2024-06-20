#include <stdio.h>
#include <stdlib.h>

// Объявление ассемблерной функции
extern long add_numbers(long a, long b);

long my_strlen(char *str) {
    long len;

    __asm__ (
        "movq %%rbx, %%rdi;"    // кладем указатель на строку из bx в di

        "xor %%rcx, %%rcx;"
        "not %%rcx;"
        "xor %%rax, %%rax;"     // будем сравнивать с нулем
        "repne scasb;"          // ищем ax в строке по адресу di

        "movq %%rdi, %%rax;"    // кладем конечное значение di в rax
        "subq %%rbx, %%rax;"    // вычтем начальное значение указателя строки
        "dec %%rax;"            // вычтем еще 1, так как di указывает на байт после нулевого символа

        : "=a" (len)            // выходное значение (длина строки из ax)
        : "b" (str)             // входное значение (указатель на строку в bx)
    );

    return len;
}

int main(void) {
    char s[] = "Hi bro I'm here";
    long len = my_strlen(s);
    printf("Strlen: %ld\n", len);

    return EXIT_SUCCESS;
}
