; Основные требования:
; - ввод 16-разрядного беззнакового числа в 10 с/с
; - вывод его как беззнакового в 16 с/с
; - вывод усеченного до 8 разрядов значения (аналогично приведению типа int к char в языке C) как знакового в 2 с/с
; - вывод минимальной целой степени двойки, которая превышает введенное число в беззнаковой интерпретации
;
; Технические требования:
; - взаимодействие с пользователем на основе меню
; - не менее пяти модулей
; - главный модуль обеспечивает вывод меню
; - главный модуль содержит массив указателей на подпрограммы, выполняющие действия, соответствующие пунктам меню.
; - обработчики действий оформлены в виде подпрограмм, находящихся каждая в отдельном модуле.
; - вызов необходимой функции осуществляется с помощью адресации по массиву индексом выбранного пункта меню.

.model small

.stack 100h

.data
    MENU_PROCEDURES dw 4 dup(?)
    MENU_MSG db '1) Input dec', 0ah, 0dh,
                '2) Output unsigned hex', 0ah, 0dh,
                '3) Output bin as char', 0ah, 0dh,
                '4) Output min power of 2', 0ah, 0dh,
                '0) Exit', 0ah, 0dh, '$'
    INPUT_ITEM_MSG db 'Enter menu item (0-4): $'

.code
extrn print_br: proc
extrn print_str: proc
extrn input_digit: proc

extrn input_dec: proc
extrn output_unsigned_hex: proc
extrn output_bin_as_char: proc
extrn output_min_power_of_2: proc

print_menu proc
    ; вывод пунктов меню
    push dx

    lea dx, MENU_MSG
    call print_str

    pop dx
    ret
print_menu endp

init_menu proc
    ; инициализация массива обработчиков пунктов меню
    push si

    lea si, OFFSET MENU_PROCEDURES

    mov word ptr [si], input_dec
    add si, 2

    mov word ptr [si], output_unsigned_hex
    add si, 2

    mov word ptr [si], output_bin_as_char
    add si, 2

    mov word ptr [si], output_min_power_of_2

    pop si
    ret
init_menu endp

input_menu_item proc
    ; ввод пункта меню в dx
    lea dx, INPUT_ITEM_MSG
    call print_str
    call input_digit
    mov dh, 0
    call print_br

    ret
input_menu_item endp

call_func proc
    push ax

    mov ax, dx
    dec al

    mov bx, 2
    mul bl

    lea bx, MENU_PROCEDURES
    add bx, ax

    call word ptr [bx]

    pop ax
    ret
call_func endp

main proc
    mov ax, @data
    mov ds, ax

    call init_menu

    loop_menu:
        call print_menu
        call input_menu_item

        cmp dl, 0
        je exit

        call call_func

        jmp loop_menu

    exit:
        mov ax, 4C00h
        int 21h
        ret
main endp

end main
