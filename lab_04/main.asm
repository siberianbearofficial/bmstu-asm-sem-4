; в матрице символов заменить все заглавные латинские буквы с четной позицией в алфавите строчными

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
