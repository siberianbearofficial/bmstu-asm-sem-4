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

end
