#include <stdio.h>

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
        "fldl %6;"           // x
        "fmull %6;"          // x^2
        "fmull %6;"          // x^3
        "faddl %2;"          // x^3 + 7
        "fcos;"              // cos(x^3 + 7)
        "fstpl %4;"          // результат в f_a

        // вычисляем середину                              mid = (a + b) / 2
        "fldl %6;"
        "faddl %7;"
        "fdivl %1;"
        "fstpl %3;"          // результат в mid

        // значение функции в середине                     f_mid = f(mid)
        "fldl %3;"           // x
        "fmull %3;"          // x^2
        "fmull %3;"          // x^3
        "faddl %2;"          // x^3 + 7
        "fcos;"              // cos(x^3 + 7)
        "fstpl %5;"          // результат в f_mid

        // проверяем на равенство нулю                     if f_mid == 0:
        "fldl %5;"           // кладем f_mid в стек
        "ftst;"
        "fstsw %%ax;"
        "fstpl %5;"          // убираем f_mid из стека
        "sahf;"
        "jz done;"           // return mid

        // if f_a * f_mid < 0:
        "fldl %4;"
        "fmull %5;"          // умножаем на значение в точке a
        "ftst;"
        "fstsw %%ax;"
        "fstpl %0;"          // убираем f_a * f_mid из стека
        "sahf;"
        "jb set_b;"  // если меньше 0, b = mid
        "jmp set_a;"  // иначе a = mid

        "set_a:"                                           // a = mid
        "fldl %3;"  // загружаем середину
        "fstpl %6;"  // сохраняем ее в a
        "loop main_loop;"
        "jmp last_mid;"

        "set_b:"                                           // b = mid
        "fldl %3;"  // загружаем середину
        "fstpl %7;"  // сохраняем ее в b
        "loop main_loop;"
        "jmp last_mid;"

        "last_mid:"  // осталось посчитать середину        // mid = (a + b) / 2
        "fldl %6;"
        "faddl %7;"
        "fdivl %1;"
        "fstpl %3;"
        "jmp done;"

        "done:"
        "fldl %3;"
        "fstpl %0;"  // результат в result

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

int main() {
    double result = root(1.5, 1.75, 10000);
    printf("%lf\n", result);
    return 0;
}
