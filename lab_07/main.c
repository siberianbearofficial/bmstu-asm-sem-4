#include <stdio.h>
#include <stdlib.h>

extern void *my_strnmove(char *destptr, const char *srcptr, size_t num);  // объявление ассемблерной функции

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
    char s[] = "Hello World!";
    long len = my_strlen(s);
    printf("Strlen: %ld\n", len);

    char s2[50];
    my_strnmove(s2, s, len);
    printf("Strnmove: %s\n", s2);

    return EXIT_SUCCESS;
}
