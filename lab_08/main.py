from math import cos


def f(value):
    return cos(value ** 3 + 7)


def root(a, b, steps):
    if f(a) * f(b) > 0:
        return None

    for _ in range(steps):
        f_a = f(a)
        mid = (a + b) / 2
        f_mid = f(mid)
        if f_mid == 0:
            return mid
        if f_a * f_mid < 0:
            b = mid
        else:
            a = mid
    mid = (a + b) / 2

    return mid


print(round(root(1.5, 1.75, 10000), 6))
