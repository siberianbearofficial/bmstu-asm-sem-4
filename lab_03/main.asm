; Программа с двумя сегментами данных.
; Ввести в первый сегмент строку из 10 символов.
; Во втором сегменте подготовить строку из 6 символов,
; заполненную пробелами и заканчивающуюся знаком $.
; Переписать из введённой строки во 2-й сегмент только символы
; на чётных позициях и вывести новую строку на экран.

data1 SEGMENT 'DATA'
buffer db 11, 0, 11 DUP ('$')
data1 ENDS

data2 SEGMENT 'DATA'
result db 5 DUP (' '), '$'
data2 ENDS

stack SEGMENT STACK 'STACK'
db 10h DUP (?)
stack ENDS

code SEGMENT 'CODE'
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

print_result proc
    ; выводим строку
    mov ah, 09h
    lea dx, result
    int 21h

    ret
print_result endp

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
code ENDS

end main
