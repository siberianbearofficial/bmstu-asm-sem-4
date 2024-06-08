# Разбор кода

Рассмотрим подробно код на языке ассемблера MASM и разберем, что для чего нужно и как работает каждая его часть.

### Сегменты данных и стек

```assembly
data1 SEGMENT 'DATA'
buffer db 11, 0, 11 DUP ('$')
data1 ENDS

data2 SEGMENT 'DATA'
result db 5 DUP (' '), '$'
data2 ENDS

stack SEGMENT STACK 'STACK'
db 10h DUP (?)
stack ENDS
```

1. **data1 SEGMENT 'DATA'**:
    - **buffer db 11, 0, 11 DUP ('$')**: Сегмент `data1` содержит буфер для ввода строки. Первые два байта используются для хранения длины строки и введенного количества символов. Затем следует 11 байтов для самой строки, которые инициализированы значением `$`.

2. **data2 SEGMENT 'DATA'**:
    - **result db 5 DUP (' '), '$'**: Сегмент `data2` содержит буфер для результата. Он инициализирован пятью пробелами и символом `$`, что используется как маркер конца строки.

3. **stack SEGMENT STACK 'STACK'**:
    - **db 10h DUP (?)**: Сегмент стека, инициализированный размером 16 байт.

### Процедуры

#### read_buffer
```assembly
read_buffer proc
    ; читаем строку
    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; выводим перенос строки
    mov ah, 02h
    mov dl, 0Ah
    int 21h

    ret
read_buffer endp
```
Процедура `read_buffer` выполняет ввод строки:
- `mov ah, 0Ah` и `lea dx, buffer`: Используется функция DOS `0Ah` для ввода строки, адрес буфера загружается в `dx`.
- `int 21h`: Вызов DOS-прерывания для ввода строки.
- `mov ah, 02h`, `mov dl, 0Ah`, `int 21h`: Вывод символа новой строки (ASCII 0Ah).

#### print_result
```assembly
print_result proc
    ; выводим строку
    mov ah, 09h
    lea dx, result
    int 21h

    ret
print_result endp
```
Процедура `print_result` выводит строку:
- `mov ah, 09h` и `lea dx, result`: Используется функция DOS `09h` для вывода строки, адрес строки загружается в `dx`.
- `int 21h`: Вызов DOS-прерывания для вывода строки.

#### copy_even_symbols
```assembly
copy_even_symbols proc
    ; si - индекс в буфере, di - индекс в результирующей строке
    mov si, offset buffer + 2  ; в первых двух байтах ожидаемое и фактическое количества символов
    mov di, offset result

    ; будем перебирать не больше 9 символов
    mov cx, 9
    next_char:
        ; читаем символ по адресу ds:si в al (si инкрементируется)
        lodsb

        ; если индекс нечетный, идем в copy_char
        test si, 1
        jnz copy_char

        ; проходим по каждому символу
        loop next_char

        ; после цикла выходим
        jmp done

    copy_char:
        ; пишем символ из al по адресу es:di (di инкрементируется)
        stosb

        ; возвращаемся в цикл
        loop next_char

    done:
        ret
copy_even_symbols endp
```
Процедура `copy_even_symbols` копирует символы с четных позиций:
- `mov si, offset buffer + 2`: Устанавливаем индекс `si` на третий байт буфера (первые два байта содержат длину строки).
- `mov di, offset result`: Устанавливаем индекс `di` на начало буфера результата.
- `mov cx, 9`: Устанавливаем счетчик `cx` на 9 (максимальное число символов).
- Цикл `next_char`:
    - `lodsb`: Читает символ из `ds:si` в `al` и инкрементирует `si`.
    - `test si, 1`: Проверяет четность индекса `si`.
    - `jnz copy_char`: Если индекс нечетный, переходим к метке `copy_char`.
    - `loop next_char`: Переход к следующей итерации цикла.
- Метка `copy_char`:
    - `stosb`: Пишет символ из `al` в `es:di` и инкрементирует `di`.
    - `loop next_char`: Переход к следующей итерации цикла.
- Метка `done`: Конец процедуры.

### Основная процедура
```assembly
main proc
    ; подключаем data1, где расположен буфер, к ds
    mov ax, data1
    mov ds, ax

    call read_buffer

    ; подключаем data2, где расположен результат, к es
    mov ax, data2
    mov es, ax

    call copy_even_symbols

    ; подключаем data2, где расположен результат, к ds
    mov ax, data2
    mov ds, ax

    call print_result

    ; завершаем программу
    mov ah, 4Ch
    int 21h

    ret
main endp
```
Процедура `main` выполняет последовательность шагов для выполнения программы:
- `mov ax, data1`, `mov ds, ax`: Устанавливаем сегмент данных `data1` для `ds`.
- `call read_buffer`: Вызов процедуры ввода строки.
- `mov ax, data2`, `mov es, ax`: Устанавливаем сегмент данных `data2` для `es`.
- `call copy_even_symbols`: Вызов процедуры копирования символов.
- `mov ax, data2`, `mov ds, ax`: Устанавливаем сегмент данных `data2` для `ds`.
- `call print_result`: Вызов процедуры вывода строки.
- `mov ah, 4Ch`, `int 21h`: Завершение программы с кодом возврата 0.

### Конец программы
```assembly
code ENDS
end main
```
- Завершение сегмента кода и указание на стартовую процедуру `main`.

Таким образом, программа осуществляет ввод строки, копирование символов с четных позиций во второй сегмент и вывод результата на экран.
