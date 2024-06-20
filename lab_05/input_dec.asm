.model small

.data
    DEC_INPUT_MSG db 'Enter a 16-bit unsigned decimal number: $'  ; 0-65535
    num dw 0

.code
public input_dec
public num

extrn print_str: proc
extrn input_digit: proc
extrn print_br: proc
extrn print_digit: proc

print_input_dec_msg proc
    ; выводим приглашение к вводу
    push dx

    lea dx, DEC_INPUT_MSG
    call print_str

    pop dx
    ret
print_input_dec_msg endp

input_dec proc
    ; ввод 16-битного беззнакового числа
    push ax
    push bx
    push cx
    push dx

    call print_input_dec_msg

    ; обнуляем значение num перед вводом
    xor ax, ax
    mov num, ax

    mov cx, 5  ; максимальное число, 65535, состоит из 5 цифр
    input_loop:
        ; вводим цифру
        call input_digit
        cmp dl, 10
        ja end_input
        mov dh, 0

        ; умножаем текущее значение num на 10
        mov ax, num
        mov bl, 10
        mul bl

        ; добавляем введенную цифру и сразу сохраняем в num
        add ax, dx
        mov num, ax

        loop input_loop

    end_input:
        call print_br

        pop dx
        pop cx
        pop bx
        pop ax
        ret
input_dec endp

end
