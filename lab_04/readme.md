# Ввод/вывод матрицы

## Версия 1

Хорошо, напишем программу на ассемблере x86, которая позволяет ввести и вывести матрицу размером до 9x9. Мы будем использовать директиву `db` для инициализации данных и использовать прерывания BIOS для вывода.

Вот программа с подробными комментариями:

```assembly
.model small
.stack 100h
.data
    ; Макс. размер матрицы
    MAXSIZE equ 9

    ; Буфер для матрицы
    matrix db MAXSIZE * MAXSIZE dup(?)

    ; Размер матрицы
    rows db ?
    cols db ?

    ; Промежуточные переменные
    i db ?
    j db ?

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Ввод числа строк и столбцов
    call InputMatrixSize

    ; Ввод элементов матрицы
    call InputMatrix

    ; Вывод элементов матрицы
    call PrintMatrix

    ; Завершение программы
    mov ax, 4C00h
    int 21h
main endp

InputMatrixSize proc
    ; Ввод числа строк
    mov ah, 01h
    int 21h
    sub al, '0'
    mov rows, al

    ; Ввод числа столбцов
    mov ah, 01h
    int 21h
    sub al, '0'
    mov cols, al

    ret
InputMatrixSize endp

InputMatrix proc
    mov cx, rows
    mov dx, cols
    xor di, di  ; индекс в буфере матрицы

InputRow:
    mov i, cx
InputCol:
    mov j, dx

    ; Ввод элемента матрицы
    mov ah, 01h
    int 21h
    sub al, '0'
    mov [matrix + di], al
    inc di

    ; Проверка конца строки
    dec j
    jnz InputCol

    ; Проверка конца матрицы
    dec i
    jnz InputRow

    ret
InputMatrix endp

PrintMatrix proc
    mov cx, rows
    mov dx, cols
    xor di, di  ; индекс в буфере матрицы

PrintRow:
    mov i, cx
PrintCol:
    mov j, dx

    ; Вывод элемента матрицы
    mov al, [matrix + di]
    add al, '0'
    mov ah, 0Eh
    int 10h
    inc di

    ; Вывод пробела между элементами
    mov al, ' '
    mov ah, 0Eh
    int 10h

    ; Проверка конца строки
    dec j
    jnz PrintCol

    ; Переход на новую строку
    mov al, 0Dh  ; возврат каретки
    mov ah, 0Eh
    int 10h
    mov al, 0Ah  ; перевод строки
    mov ah, 0Eh
    int 10h

    ; Проверка конца матрицы
    dec i
    jnz PrintRow

    ret
PrintMatrix endp

end main
```

### Пояснение

1. **Инициализация сегментов:**
   ```assembly
   mov ax, @data
   mov ds, ax
   ```
   Мы инициализируем сегмент данных, чтобы иметь доступ к нашим переменным.

2. **Ввод числа строк и столбцов:**
   Функция `InputMatrixSize` использует прерывание `int 21h` с функцией `01h` для ввода символа с клавиатуры. Мы переводим ASCII код символа в число, вычитая '0'.

3. **Ввод элементов матрицы:**
   Функция `InputMatrix` заполняет матрицу элементами, введенными с клавиатуры. Используется вложенный цикл для ввода элементов по строкам и столбцам.

4. **Вывод элементов матрицы:**
   Функция `PrintMatrix` выводит элементы матрицы на экран с использованием BIOS прерывания `int 10h`, функция `0Eh` для вывода символа. Между элементами выводится пробел, а после каждой строки - возврат каретки и перевод строки.

5. **Завершение программы:**
   ```assembly
   mov ax, 4C00h
   int 21h
   ```
   Программа завершает работу, возвращая управление DOS.

Эта программа вводит размер матрицы, затем запрашивает ввод элементов и выводит их на экран в виде матрицы.

## Версия 2

Использование массива указателей на строки матрицы требует более сложного управления памятью, но это возможно. Мы будем использовать сегмент стека для хранения указателей на строки и сегмент данных для хранения самих элементов матрицы. Вот как это сделать:

```assembly
.model small
.stack 100h
.data
    ; Макс. размер матрицы
    MAXSIZE equ 9

    ; Буфер для матрицы
    matrix db MAXSIZE * MAXSIZE dup(?)

    ; Указатели на строки матрицы
    row_ptrs dw MAXSIZE dup(?)

    ; Размер матрицы
    rows db ?
    cols db ?

    ; Промежуточные переменные
    i db ?
    j db ?

.code
main proc
    mov ax, @data
    mov ds, ax
    mov es, ax  ; используем сегмент ES для указателей на строки

    ; Ввод числа строк и столбцов
    call InputMatrixSize

    ; Инициализация указателей на строки
    call InitRowPointers

    ; Ввод элементов матрицы
    call InputMatrix

    ; Вывод элементов матрицы
    call PrintMatrix

    ; Завершение программы
    mov ax, 4C00h
    int 21h
main endp

InputMatrixSize proc
    ; Ввод числа строк
    mov ah, 01h
    int 21h
    sub al, '0'
    mov rows, al

    ; Ввод числа столбцов
    mov ah, 01h
    int 21h
    sub al, '0'
    mov cols, al

    ret
InputMatrixSize endp

InitRowPointers proc
    mov cx, rows
    xor di, di          ; индекс в row_ptrs
    xor bx, bx          ; индекс в matrix

InitRow:
    ; вычисление адреса строки
    lea si, matrix[bx]
    ; сохранение адреса строки в row_ptrs
    mov [es:row_ptrs + di], si
    add di, 2           ; увеличение индекса на 2 (размер указателя)
    add bx, MAXSIZE     ; переход к следующей строке

    dec cx
    jnz InitRow

    ret
InitRowPointers endp

InputMatrix proc
    mov cx, rows

InputRow:
    mov dx, cols
    mov bx, cx
    dec bx
    shl bx, 1           ; умножение на 2 для индексации указателей
    mov si, [es:row_ptrs + bx]

InputCol:
    ; Ввод элемента матрицы
    mov ah, 01h
    int 21h
    sub al, '0'
    mov [si], al
    inc si

    dec dx
    jnz InputCol

    dec cx
    jnz InputRow

    ret
InputMatrix endp

PrintMatrix proc
    mov cx, rows

PrintRow:
    mov dx, cols
    mov bx, cx
    dec bx
    shl bx, 1           ; умножение на 2 для индексации указателей
    mov si, [es:row_ptrs + bx]

PrintCol:
    ; Вывод элемента матрицы
    mov al, [si]
    add al, '0'
    mov ah, 0Eh
    int 10h
    inc si

    ; Вывод пробела между элементами
    mov al, ' '
    mov ah, 0Eh
    int 10h

    dec dx
    jnz PrintCol

    ; Переход на новую строку
    mov al, 0Dh  ; возврат каретки
    mov ah, 0Eh
    int 10h
    mov al, 0Ah  ; перевод строки
    mov ah, 0Eh
    int 10h

    dec cx
    jnz PrintRow

    ret
PrintMatrix endp

end main
```

### Пояснение

1. **Инициализация сегментов:**
   ```assembly
   mov ax, @data
   mov ds, ax
   mov es, ax  ; используем сегмент ES для указателей на строки
   ```
   Мы инициализируем сегмент данных (DS) и сегмент дополнительного стека (ES) для работы с указателями на строки.

2. **Ввод числа строк и столбцов:**
   Функция `InputMatrixSize` использует прерывание `int 21h` с функцией `01h` для ввода символа с клавиатуры и переводит ASCII код символа в число, вычитая '0'.

3. **Инициализация указателей на строки:**
   Функция `InitRowPointers` заполняет массив `row_ptrs` указателями на начала строк матрицы. Мы используем команду `lea` для вычисления адреса элемента массива и сохраняем его в `row_ptrs`.

4. **Ввод элементов матрицы:**
   Функция `InputMatrix` заполняет матрицу элементами, введенными с клавиатуры. Она использует указатели на строки для размещения элементов.

5. **Вывод элементов матрицы:**
   Функция `PrintMatrix` выводит элементы матрицы на экран, используя BIOS прерывание `int 10h`, функция `0Eh` для вывода символа. Между элементами выводится пробел, а после каждой строки - возврат каретки и перевод строки.

6. **Завершение программы:**
   ```assembly
   mov ax, 4C00h
   int 21h
   ```
   Программа завершает работу, возвращая управление DOS.

Таким образом, наша программа использует массив указателей на строки для представления матрицы в памяти, что позволяет более гибко управлять ее элементами.
