section .text
    global _add_numbers

_add_numbers:
    ; Входные параметры:
    ; rdi - первое число
    ; rsi - второе число
    ; Возвращаемое значение:
    ; rax - результат сложения

    ; Выполнение сложения
    mov rax, rdi
    add rax, rsi

    ; Завершение функции
    ret
