.model small

.data
    HEX_OUTPUT_MSG db 'The number in hexadecimal: ', '$'
    HEX_DIGITS db '0123456789ABCDEF$'

.code
public output_unsigned_hex

extrn print_br: proc
extrn print_str: proc
extrn print_sym: proc

extrn num: word

print_unsigned_hex_msg proc
    ; вывод пояснения
    push dx

    lea dx, HEX_OUTPUT_MSG
    call print_str

    pop dx
    ret
print_unsigned_hex_msg endp

output_unsigned_hex proc
    ; вывод беззнакового числа в 16 с/с
    push ax
    push cx
    push dx
    push di

    call print_unsigned_hex_msg

    mov ax, num

    mov cx, 4  ; будет 4 цифры в 16 с/с
    hex_output_loop:
        ; получаем цифру по индексу
        mov di, ax
        and di, 0Fh
        mov dl, HEX_DIGITS[di]

        push dx  ; кладем цифру в стек

        ; сдвигаем число на 4 разрада вправо
        push cx
        mov cl, 4
        shr ax, cl
        pop cx

        loop hex_output_loop

    mov cx, 4
    hex_print_loop:
        pop dx  ; достаем цифру из стека
        call print_sym
        loop hex_print_loop

    call print_br

    pop di
    pop dx
    pop cx
    pop ax
    ret
output_unsigned_hex endp

end
