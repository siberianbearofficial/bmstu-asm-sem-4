#include "root.h"

/**
 * Поиск корня функции cos(x^3 + 7) методом половинного деления.
 * @param a: начало отрезка
 * @param b: конец отрезка
 * @param steps: количество шагов
 * @return: найденный корень
 * @author: Орлов Алексей ИУ7-44Б
 */
double root(double a, double b, int steps) {
    double result;
    double c2 = 2, c7 = 7;
    double mid, f_a, f_mid;

    __asm__ (
        // for _ in range(steps):
        "main_loop:"

        // значение функции в точке a                      f_a = f(a)
        "fld %6;"           // x
        "fmul %6;"          // x^2
        "fmul %6;"          // x^3
        "fadd %2;"          // x^3 + 7
        "fcos;"             // cos(x^3 + 7)
        "fstp %4;"          // результат в f_a

        // вычисляем середину                              mid = (a + b) / 2
        "fld %6;"
        "fadd %7;"
        "fdiv %1;"
        "fstp %3;"          // результат в mid

        // значение функции в середине                     f_mid = f(mid)
        "fld %3;"           // x
        "fmul %3;"          // x^2
        "fmul %3;"          // x^3
        "fadd %2;"          // x^3 + 7
        "fcos;"             // cos(x^3 + 7)
        "fstp %5;"          // результат в f_mid

        // проверяем на равенство нулю                     if f_mid == 0:
        "fld %5;"           // кладем f_mid в стек
        "ftst;"
        "fstsw %%ax;"
        "fstp %5;"          // убираем f_mid из стека
        "sahf;"
        "jz done;"          // return mid

        // if f_a * f_mid < 0:
        "fld %4;"
        "fmul %5;"          // умножаем на значение в точке a
        "ftst;"
        "fstsw %%ax;"
        "fstp %0;"          // убираем f_a * f_mid из стека
        "sahf;"
        "jb set_b;"   // если меньше 0, b = mid
        "jmp set_a;"  // иначе a = mid

        "set_a:"                                           // a = mid
        "fld %3;"   // загружаем середину
        "fstp %6;"  // сохраняем ее в a
        "loop main_loop;"
        "jmp last_mid;"

        "set_b:"                                           // b = mid
        "fld %3;"   // загружаем середину
        "fstp %7;"  // сохраняем ее в b
        "loop main_loop;"
        "jmp last_mid;"

        "last_mid:" // осталось посчитать середину        // mid = (a + b) / 2
        "fld %6;"
        "fadd %7;"
        "fdiv %1;"
        "fstp %3;"
        "jmp done;"

        "done:"
        "fld %3;"
        "fstp %0;"  // результат в result

        // Выходные данные:
        : "=m"(result)
        //       0

        // Входные данные:
        : "m"(c2), "m"(c7), "m"(mid), "m"(f_a), "m"(f_mid), "m"(a), "m"(b), "c"(steps)
        //    1        2         3         4          5         6       7         8

        // Изменили:
        : "rax"
    );

    return result;
}

extern char steps_buffer[1000];

void root_str(char *a_str, char *b_str, char *steps_str)
{
    double a = 0, b = 0; int steps = 0;
    sscanf(a_str, "%lf", &a);
    sscanf(b_str, "%lf", &b);
    sscanf(steps_str, "%d", &steps);

    double r = root(a, b, steps);

    printf("Root: %lf\n", r);
    sprintf(steps_buffer, "%lf", r);
}
