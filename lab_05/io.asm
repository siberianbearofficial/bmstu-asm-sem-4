.model small

.data
    SEP equ ' '

.code
public print_sym
public print_sep
public print_br
public print_str
public print_digit
public print_hex

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

print_digit proc
    ; вывод цифры из dl
    push dx

    add dl, '0'
    call print_sym

    pop dx
    ret
print_digit endp

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

print_hex proc
    ; вывод 16-битного числа в 16 с/с
    push cx
    push dx

    mov cx, dx

    mov dl, ch
    call print_digit

    mov dl, cl
    call print_digit

    pop cx
    pop dx
    ret
print_hex endp

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
