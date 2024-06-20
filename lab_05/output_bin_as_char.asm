.model small

.data
    BIN_OUTPUT_MSG db 'The number as a signed char in binary: ', '$'

.code
public output_bin_as_char

extrn print_br: proc
extrn print_str: proc
extrn print_digit: proc

extrn num: word

print_0 proc
    ; вывод 0
    push dx

    mov dl, 0
    call print_digit

    pop dx
    ret
print_0 endp

print_1 proc
    ; вывод 1
    push dx

    mov dl, 1
    call print_digit

    pop dx
    ret
print_1 endp

print_bin_output_msg proc
    ; вывод пояснения
    push dx

    lea dx, BIN_OUTPUT_MSG
    call print_str

    pop dx
    ret
print_bin_output_msg endp

output_bin_as_char proc
    ; вывод числа как знакового char в двоичной форме
    push ax
    push cx
    push dx

    call print_bin_output_msg

    mov ax, num
    and ax, 0FFh  ; Берем младшие 8 бит числа

    ; Преобразуем значение в знаковое 8-битное число
    cmp ax, 80h
    jl not_negative
    sub ax, 100h

    not_negative:
        ; Подготовка для вывода двоичного представления
        mov cx, 8
        mov dx, ax
        shl dx, cl  ; Переносим значение в старшую часть регистра для вывода битов

    bin_output_loop:
        rol dx, 1  ; Циклический сдвиг влево через флаг
        jc bin_print_1
        jmp bin_print_0

    bin_print_0:
        call print_0
        jmp bin_next

    bin_print_1:
        call print_1
        jmp bin_next

    bin_next:
        loop bin_output_loop

    call print_br

    pop dx
    pop cx
    pop ax
    ret
output_bin_as_char endp

end
