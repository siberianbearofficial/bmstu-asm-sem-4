.model small

.data
    POWER_OF_2_MSG db 'The smallest power of 2 greater than the number: ', '$'

.code
public output_min_power_of_2

extrn print_br: proc
extrn print_str: proc
extrn print_digit: proc
extrn print_hex: proc

extrn num: word

print_power_of_2_msg proc
    ; вывод пояснения
    push dx

    lea dx, POWER_OF_2_MSG
    call print_str

    pop dx
    ret
print_power_of_2_msg endp

print_dec proc
    ; вывод десятичного числа из dx
    push ax
    push bx
    push cx
    push dx

    mov ax, dx  ; перемещаем значение в ax для работы с ним
    mov bx, 10  ; будем делить число на 10

    ; складываем цифры числа в стек
    xor cx, cx
    .repeat
        xor dx, dx  ; обнуляем dx перед делением
        div bx
        push dx  ; кладем цифру в стек
        inc cx
    .until ax == 0

    ; выводим цифры числа из стека
    print_stack:
        pop dx  ; достаем цифру из стека
        call print_digit
        loop print_stack

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_dec endp

output_min_power_of_2 proc
    ; вывод минимальной степени двойки, превышающей введенное число
    push ax
    push dx

    call print_power_of_2_msg

    mov dx, 0  ; минимальная степень двойки
    mov ax, 1  ; число в минимальной степени двойки

    power_loop:
        cmp ax, num
        ja power_done

        shl ax, 1
        inc dx
        jmp power_loop

    power_done:
        call print_dec
        call print_br

        pop dx
        pop ax
        ret
output_min_power_of_2 endp

end
