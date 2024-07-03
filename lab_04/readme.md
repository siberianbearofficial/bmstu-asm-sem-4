# Разбор кода

Код на языке ассемблера MASM выполняет замену всех заглавных латинских букв с четной позицией в алфавите на
строчные в матрице символов. Рассмотрим основные части кода, функции, их назначение и технические детали реализации.

### **main.asm**

Файл `main.asm` содержит основной код, который вызывает три основных
процедуры: `input_matrix`, `lower_cap_let_even_ind_matrix` и `print_matrix`.

```asm
.model small

.stack 200h

.data
    MAXSIZE equ 9  ; максимальный размер матрицы
    matrix db MAXSIZE * MAXSIZE DUP (?)  ; буфер матрицы
    max_row_ind dw 0  ; максимальный допустимый индекс строки
    max_col_ind dw 0  ; максимальный допустимый индекс столбца

.code
extrn input_matrix: proc
extrn lower_cap_let_even_ind_matrix: proc
extrn print_matrix: proc

public MAXSIZE
public matrix
public max_row_ind
public max_col_ind

main proc
    mov ax, @data
    mov ds, ax

    call input_matrix
    call lower_cap_let_even_ind_matrix
    call print_matrix

    mov ax, 4C00h
    int 21h
    ret
main endp

end main
```

#### Объяснение:

- **Директивы и переменные:**
    - `.model small` и `.stack 200h`: Определяет модель памяти и размер стека.
    - `MAXSIZE`, `matrix`, `max_row_ind`, `max_col_ind`: Определение констант и переменных для матрицы и ее размеров.

- **Код процедуры `main`:**
    - Инициализация сегмента данных.
    - Вызов процедур для ввода матрицы (`input_matrix`), замены букв (`lower_cap_let_even_ind_matrix`) и вывода
      матрицы (`print_matrix`).
    - Завершение программы с помощью `mov ax, 4C00h` и `int 21h`.

### **matrix.asm**

Файл `matrix.asm` содержит процедуры для работы с матрицей, включая ввод, вывод и замену символов.

```asm
.model small

.data
    i dw 0  ; индекс строки

.code
extrn matrix: byte
extrn max_row_ind: word
extrn max_col_ind: word

extrn lower_cap_let_even_ind: proc

extrn print_sym: proc
extrn print_sep: proc
extrn print_br: proc
extrn print_str: proc

extrn input_sym: proc
extrn input_digit: proc

public input_matrix
public lower_cap_let_even_ind_matrix
public print_matrix

calculate_index proc
    ; вычисление индекса элемента matrix[i][cx] в bx
    push ax
    push dx

    mov ax, i
    mov dx, max_col_ind
    add dx, 1
    mul dx
    add ax, cx
    mov bx, ax  ; результат вычислений в bx

    pop dx
    pop ax
    ret
calculate_index endp
```

#### Объяснение:

- **calculate_index:**
    - Вычисляет линейный индекс элемента матрицы по строке и столбцу и сохраняет результат в `bx`.

#### Процедуры ввода и вывода:

```asm
input_max_row_ind proc
    ; ввод максимального индекса строки
    push dx

    input_row_size:
        call input_digit
        mov dh, 0
        call print_br

        sub dl, 1
        mov max_row_ind, dx

        pop dx
        ret
input_max_row_ind endp

input_max_col_ind proc
    ; ввод максимального индекса столбца
    push dx

    input_col_size:
        call input_digit
        mov dh, 0
        call print_br

        sub dl, 1
        mov max_col_ind, dx

        pop dx
        ret
input_max_col_ind endp

input_size proc
    ; ввод размеров матрицы
    call input_max_row_ind
    call input_max_col_ind

    ret
input_size endp
```

- **input_max_row_ind и input_max_col_ind:**
    - Вводят максимальные индексы строк и столбцов. Значения вводятся в виде цифр, которые затем преобразуются в
      значения и сохраняются в соответствующие переменные.

#### Процедуры ввода и вывода строк:

```asm
input_row proc
    ; ввод i-ой строки
    push bx
    push cx
    push dx

    xor cx, cx
    loop_j:
        call calculate_index  ; вычисление индекса в bx
        call input_sym  ; ввод символа в dl
        mov [matrix][bx], dl  ; сохранение символа в матрицу

        call print_sep

        cmp cx, max_col_ind
        inc cx
        jb loop_j

    pop dx
    pop cx
    pop bx
    ret
input_row endp

input_matrix proc
    ; ввод матрицы
    push cx

    call input_size

    xor cx, cx
    loop_i:
        mov i, cx
        call input_row
        call print_br

        cmp cx, max_row_ind
        inc cx
        jb loop_i

    pop cx
    ret
input_matrix endp
```

- **input_row и input_matrix:**
    - `input_row` вводит одну строку матрицы.
    - `input_matrix` вводит всю матрицу, используя `input_row` для каждой строки.

#### Процедуры вывода строк и матрицы:

```asm
print_row proc
    ; вывод i-ой строки
    push bx
    push cx
    push dx

    xor cx, cx
    loop_j:
        call calculate_index  ; вычисление индекса в bx

        mov dl, [matrix][bx]  ; загрузка символа из матрицы
        call print_sym
        call print_sep

        cmp cx, max_col_ind
        inc cx
        jb loop_j

    pop dx
    pop cx
    pop bx
    ret
print_row endp

print_matrix proc
    ; вывод матрицы
    push cx

    xor cx, cx
    loop_i:
        mov i, cx
        call print_row
        call print_br

        cmp cx, max_row_ind
        inc cx
        jb loop_i

    pop cx
    ret
print_matrix endp
```

- **print_row и print_matrix:**
    - `print_row` выводит одну строку матрицы.
    - `print_matrix` выводит всю матрицу, используя `print_row` для каждой строки.

#### Процедуры замены символов:

```asm
lower_cap_let_even_ind_row proc
    push bx
    push cx
    push dx

    xor cx, cx
    loop_j:
        call calculate_index  ; вычисление индекса в bx
        mov dl, [matrix][bx]  ; загрузка символа из матрицы

        call lower_cap_let_even_ind  ; меняем символ в dl, если надо
        mov [matrix][bx], dl  ; сохранение символа в матрицу

        cmp cx, max_col_ind
        inc cx
        jb loop_j

    pop dx
    pop cx
    pop bx
    ret
lower_cap_let_even_ind_row endp

lower_cap_let_even_ind_matrix proc
    push cx

    xor cx, cx
    loop_i:
        mov i, cx
        call lower_cap_let_even_ind_row

        cmp cx, max_row_ind
        inc cx
        jb loop_i

    pop cx
    ret
lower_cap_let_even_ind_matrix endp
```

- **lower_cap_let_even_ind_row и lower_cap_let_even_ind_matrix:**
    - `lower_cap_let_even_ind_row` обрабатывает одну строку матрицы, заменяя заглавные буквы с четной позицией в
      алфавите на строчные.
    - `lower_cap_let_even_ind_matrix` обрабатывает всю матрицу, используя `lower_cap_let_even_ind_row` для каждой
      строки.

### **lowercase.asm**

Файл `lowercase.asm` содержит процедуры для проверки и замены символов.

```asm
.model small

.code
public lower_cap_let_even_ind

lower_let proc
    ; сделать букву строчной
    add dl, 32

    ret
lower_let endp

lower_let_even_ind proc
    ; сделать заглавную букву строчной
    push ax

    mov al, dl
    sub al, 'A'
    test al, 1
    jnz skip_even
    call lower_let

    skip_even:
        pop ax
        ret
lower_let_even_ind endp

lower_cap_let_even_ind proc
    ; сделать заглавную букву с четной позицией в алфавите строчной
    cmp dl, 'A'
    jb skip_cap
    cmp dl, 'Z'
    ja skip_cap
    call lower_let_even_ind

    skip_cap:
        ret
lower_cap_let_even_ind endp

end
```

#### Объяснение:

- **lower_let:**
    - Преобразует заглавную букву в строчную

, добавляя 32 к коду символа.

- **lower_let_even_ind:**
    - Проверяет, является ли заглавная буква четной по позиции в алфавите и, если да, вызывает `lower_let`.

- **lower_cap_let_even_ind:**
    - Проверяет, является ли символ заглавной буквой и вызывает `lower_let_even_ind`, если это так.

### **io.asm**

Файл `io.asm` содержит процедуры для ввода и вывода символов.

```asm
.model small

.data
    SEP equ ' '

.code
public print_sym
public print_sep
public print_br
public print_str

public input_sym
public input_digit

print_sym proc
    ; вывод символа из dl
    push ax

    mov ah, 02h
    int 21h

    pop ax
    ret
print_sym endp

print_sep proc
    ; вывод разделителя
    push dx

    mov dl, SEP
    call print_sym

    pop dx
    ret
print_sep endp

print_br proc
    ; возврат каретки и перевод строки
    push dx

    mov dl, 0Ah
    call print_sym

    mov dl, 0Dh
    call print_sym

    pop dx
    ret
print_br endp

print_str proc
    ; вывод строки из ds:dx
    push ax

    mov ah, 09h
    int 21h

    pop ax
    ret
print_str endp

input_sym proc
    ; ввод символа в dl
    push ax

    mov ah, 01h
    int 21h
    mov dl, al

    pop ax
    ret
input_sym endp

input_digit proc
    ; ввод цифры в dl

    call input_sym
    sub dl, '0'

    ret
input_digit endp

end
```

#### Объяснение:

- **Процедуры ввода и вывода:**
    - `print_sym`, `print_sep`, `print_br`, `print_str`: Процедуры для вывода символов и строк.
    - `input_sym`, `input_digit`: Процедуры для ввода символов и цифр.

### Заключение

Вместе эти файлы реализуют программу на ассемблере MASM для работы с матрицей символов, включая ввод, обработку (замена
заглавных букв на строчные для четных позиций в алфавите) и вывод. Основные моменты включают работу с индексами матрицы,
проверку и преобразование символов, а также использование системных прерываний для ввода и вывода данных.

Для лучшего понимания происходящего удобно пользоваться таблицей ASCII символов: https://theasciicode.com.ar/
